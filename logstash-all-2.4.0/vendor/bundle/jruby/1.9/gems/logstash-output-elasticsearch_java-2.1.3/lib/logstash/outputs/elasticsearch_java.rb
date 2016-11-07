# encoding: utf-8
require "logstash/namespace"
require "logstash/environment"
require "logstash/outputs/base"
require "logstash/json"
require "concurrent"
require "socket" # for Socket.gethostname
require "thread" # for safe queueing
require "uri" # for escaping user input
require "logstash/outputs/elasticsearch_java/protocol"
require "logstash/outputs/elasticsearch"

# This output lets you store logs in Elasticsearch using the native 'node' and 'transport'
# protocols. It is highly recommended to use the regular 'logstash-output-elasticsearch' output
# which uses HTTP instead. This output is, in-fact, sometimes slower, and never faster than that one.
# Additionally, upgrading your Elasticsearch cluster may require you to simultaneously update this
# plugin for any protocol level changes. The HTTP client may be easier to work with due to wider
# familiarity with HTTP.
#
# *VERSION NOTE*: Your Elasticsearch cluster must be running Elasticsearch 1.0.0 or later.
#
# If you want to set other Elasticsearch options that are not exposed directly
# as configuration options, there are two methods:
#
# * Create an `elasticsearch.yml` file in the $PWD of the Logstash process
# * Pass in es.* java properties (`java -Des.node.foo=` or `ruby -J-Des.node.foo=`)
#
# With the default `protocol` setting ("node"), this plugin will join your
# Elasticsearch cluster as a client node, so it will show up in Elasticsearch's
# cluster status.
#
# You can learn more about Elasticsearch at <https://www.elastic.co/products/elasticsearch>
#
# ==== Operational Notes
#
# If using the default `protocol` setting ("node"), your firewalls might need
# to permit port 9300 in *both* directions (from Logstash to Elasticsearch, and
# Elasticsearch to Logstash)
#
# ==== Retry Policy
#
# By default all bulk requests to ES are synchronous. Not all events in the bulk requests
# always make it successfully. For example, there could be events which are not formatted
# correctly for the index they are targeting (type mismatch in mapping). So that we minimize loss of 
# events, we have a specific retry policy in place. We retry all events which fail to be reached by 
# Elasticsearch for network related issues. We retry specific events which exhibit errors under a separate 
# policy described below. Events of this nature are ones which experience ES error codes described as 
# retryable errors.
#
# *Retryable Errors:*
#
# - 429, Too Many Requests (RFC6585)
# - 503, The server is currently unable to handle the request due to a temporary overloading or maintenance of the server.
# 
# Here are the rules of what is retried when:
#
# - Block and retry all events in bulk response that experiences transient network exceptions until
#   a successful submission is received by Elasticsearch.
# - Retry subset of sent events which resulted in ES errors of a retryable nature which can be found 
#   in RETRYABLE_CODES
# - For events which returned retryable error codes, they will be pushed onto a separate queue for 
#   retrying events. events in this queue will be retried a maximum of 5 times by default (configurable through :max_retries). The size of 
#   this queue is capped by the value set in :retry_max_items.
# - Events from the retry queue are submitted again either when the queue reaches its max size or when
#   the max interval time is reached, which is set in :retry_max_interval.
# - Events which are not retryable or have reached their max retry count are logged to stderr.
class LogStash::Outputs::ElasticSearchJava < LogStash::Outputs::Base
  attr_reader :client

  include LogStash::Outputs::ElasticSearch::CommonConfigs
  include LogStash::Outputs::ElasticSearch::Common

  RETRYABLE_CODES = [409, 429, 503]
  SUCCESS_CODES = [200, 201]

  config_name "elasticsearch_java"

  # The Elasticsearch action to perform. Valid actions are:
  #
  # - index: indexes a document (an event from Logstash).
  # - delete: deletes a document by id (An id is required for this action)
  # - create: indexes a document, fails if a document by that id already exists in the index.
  # - update: updates a document by id. Update has a special case where you can upsert -- update a
  #   document if not already present. See the `upsert` option
  # - create_unless_exists: create the document unless it already exists, in which case do nothing.
  #
  # For more details on actions, check out the http://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html[Elasticsearch bulk API documentation]
  config :action, :validate => %w(index delete create update create_unless_exists), :default => "index"

  # The name of your cluster if you set it on the Elasticsearch side. Useful
  # for discovery when using `node` or `transport` protocols.
  # By default, it looks for a cluster named 'elasticsearch'.
  # Equivalent to the Elasticsearch option 'cluster.name'
  config :cluster, :validate => :string

  # This sets the local port to bind to. Equivalent to the Elasticsrearch option 'transport.tcp.port'
  config :transport_tcp_port, :validate => :number

  # This setting no longer does anything. It exists to keep config validation
  # from failing. It will be removed in future versions.
  config :max_inflight_requests, :validate => :number, :default => 50, :deprecated => true

  # The node name Elasticsearch will use when joining a cluster.
  #
  # By default, this is generated internally by the ES client.
  config :node_name, :validate => :string

  # Choose the protocol used to talk to Elasticsearch.
  #
  # The 'node' protocol (default) will connect to the cluster as a normal Elasticsearch
  # node (but will not store data). If you use the `node` protocol, you must permit
  # bidirectional communication on the port 9300 (or whichever port you have
  # configured).
  #
  # If you do not specify the `host` parameter, it will use  multicast for http://www.elastic.co/guide/en/elasticsearch/reference/current/modules-discovery-zen.html[Elasticsearch discovery].  While this may work in a test/dev environment where multicast is enabled in 
  # Elasticsearch, we strongly recommend http://www.elastic.co/guide/en/elasticsearch/guide/current/important-configuration-changes.html#unicast[using unicast]
  # in Elasticsearch.  To connect to an Elasticsearch cluster with unicast,
  # you must include the `host` parameter (see relevant section above).  
  #
  # The 'transport' protocol will connect to the host you specify and will
  # not show up as a 'node' in the Elasticsearch cluster. This is useful
  # in situations where you cannot permit connections outbound from the
  # Elasticsearch cluster to this Logstash server.
  #
  # All protocols will use bulk requests when talking to Elasticsearch.
  config :protocol, :validate => [ "node", "transport"], :default => "transport"

  # Enable cluster sniffing (transport only).
  # Asks host for the list of all cluster nodes and adds them to the hosts list
  # Equivalent to the Elasticsearch option 'client.transport.sniff'
  config :sniffing, :validate => :boolean, :default => false

  # The name/address of the host to bind to for Elasticsearch clustering. Equivalent to the Elasticsearch option 'network.host'
  # option.
  # This MUST be set for either protocol to work (node or transport)! The internal Elasticsearch node
  # will bind to this ip. This ip MUST be reachable by all nodes in the Elasticsearch cluster
  config :network_host, :validate => :string, :required => true

  def client_options
    client_settings = {}
    client_settings["cluster.name"] = @cluster if @cluster
    client_settings["network.host"] = @network_host if @network_host
    client_settings["transport.tcp.port"] = @transport_tcp_port if @transport_tcp_port
    client_settings["client.transport.sniff"] = @sniffing

    if @node_name
      client_settings["node.name"] = @node_name
    else
      client_settings["node.name"] = "logstash-#{Socket.gethostname}-#{$$}-#{object_id}"
    end

    options = {
      :protocol => @protocol,
      :client_settings => client_settings,
      :hosts => @hosts
    }

    # Update API setup
    update_options = {
      :upsert => @upsert,
      :doc_as_upsert => @doc_as_upsert
    }
    options.merge! update_options if @action == 'update'

    options
  end

  def build_client
    @client = client_class.new(client_options)
  end

  def close
    @stopping.make_true
    @buffer.stop
  end

  def get_plugin_options
    @@plugins.each do |plugin|
      name = plugin.name.split('-')[-1]
      client_settings.merge!(LogStash::Outputs::ElasticSearchJava.const_get(name.capitalize).create_client_config(self))
    end
  end

  def client_class
    case @protocol
      when "transport"
        LogStash::Outputs::ElasticSearchJavaPlugins::Protocols::TransportClient
      when "node"
        LogStash::Outputs::ElasticSearchJavaPlugins::Protocols::NodeClient
    end
  end

  @@plugins = Gem::Specification.find_all{|spec| spec.name =~ /logstash-output-elasticsearch_java_/ }

  @@plugins.each do |plugin|
    name = plugin.name.split('_')[-1]
    require "logstash/outputs/elasticsearch_java/#{name}"
  end

end # class LogStash::Outputs::ElasticSearchJava
