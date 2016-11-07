require "cabin"
require "base64"
require 'logstash-output-elasticsearch_java_jars.rb'
require 'logstash/outputs/elasticsearch_java'

module LogStash module Outputs module ElasticSearchJavaPlugins module Protocols
  DEFAULT_OPTIONS = {
    :port => 9300,
    :elasticsearch_plugins => []
  }

  class NodeClient
    attr_reader :settings, :client_options

    CLIENT_MUTEX = Mutex.new

    def initialize(options={})
      @logger = Cabin::Channel.get
      @client_options = DEFAULT_OPTIONS.merge(options)
      create_settings
    end

    def client_mutex_synchronize
      CLIENT_MUTEX.synchronize { yield }
    end

    def client
      client_mutex_synchronize { @@client ||= make_client }
    end

    # For use in test helpers
    def self.clear_node_client
      client_mutex_synchronize { @@client = nil }
    end

    def create_settings
      @settings = org.elasticsearch.common.settings.Settings.settingsBuilder()
      if @client_options[:hosts]
        @settings.put("discovery.zen.ping.multicast.enabled", false)
        @settings.put("discovery.zen.ping.unicast.hosts", hosts(@client_options))
      end

      @settings.put("node.client", true)
      @settings.put("http.enabled", false)
      @settings.put("path.home", Dir.pwd)

      if @client_options[:client_settings]
        @client_options[:client_settings].each do |key, value|
          @settings.put(key, value)
        end
      end

      @settings
    end

    def hosts(options)
      # http://www.elasticsearch.org/guide/reference/modules/discovery/zen/
      result = Array.new
      if options[:hosts].class == Array
        options[:hosts].each do |host|
          if host.to_s =~ /^.+:.+$/
            # For host in format: host:port, ignore options[:port]
            result << host
          else
            if options[:port].to_s =~ /^\d+-\d+$/
              # port ranges are 'host[port1-port2]'b
              result << Range.new(*options[:port].split("-")).collect { |p| "#{host}:#{p}" }
            else
              result << "#{host}:#{options[:port]}"
            end
          end
        end
      else
        if options[:hosts].to_s =~ /^.+:.+$/
          # For host in format: host:port, ignore options[:port]
          result << options[:hosts]
        else
          if options[:port].to_s =~ /^\d+-\d+$/
            # port ranges are 'host[port1-port2]' according to
            # http://www.elasticsearch.org/guide/reference/modules/discovery/zen/
            # However, it seems to only query the first port.
            # So generate our own list of unicast hosts to scan.
            range = Range.new(*options[:port].split("-"))
            result << range.collect { |p| "#{options[:hosts]}:#{p}" }
          else
            result << "#{options[:hosts]}:#{options[:port]}"
          end
        end
      end
      result.flatten.join(",")
    end

    # Normalizes the Java response to a reasonable approximation of the HTTP datastructure for interop
    # with the HTTP code
    def normalize_bulk_response(bulk_response)
      # TODO(talevy): parse item response objects to retrieve correct 200 (OK) or 201(created) status codes		+            items = bulk_response.map {|i|
      items = bulk_response.map { |i|
        if i.is_failed
          [[i.get_op_type, {"status" => i.get_failure.get_status.get_status, "message" => i.failureMessage}]]
        else
          [[i.get_op_type, {"status" => 200, "message" => "OK"}]]
        end
      }
      if bulk_response.has_failures()
        {"errors" => true, "items" => items}
      else
        {"errors" => false}
      end
    end

    def make_client
      nodebuilder = org.elasticsearch.node.NodeBuilder.nodeBuilder
      nodebuilder.settings(settings.build).node().client()
    end

    def bulk(actions)
      # Actions an array of [ action, action_metadata, source ]
      prep = client.prepareBulk
      actions.each do |action, args, source|
        prep.add(build_request(action, args, source))
      end
      response = prep.execute.actionGet()

      self.normalize_bulk_response(response)
    end

    # def bulk

    def build_request(action, args, source)
      case action
        when "index"
          request = org.elasticsearch.action.index.IndexRequest.new(args[:_index])
          request.id(args[:_id]) if args[:_id]
          request.routing(args[:_routing]) if args[:_routing]
          request.source(source)
        when "delete"
          request = org.elasticsearch.action.delete.DeleteRequest.new(args[:_index])
          request.id(args[:_id])
          request.routing(args[:_routing]) if args[:_routing]
        when "create"
          request = org.elasticsearch.action.index.IndexRequest.new(args[:_index])
          request.id(args[:_id]) if args[:_id]
          request.routing(args[:_routing]) if args[:_routing]
          request.source(source)
          request.opType("create")
        when "create_unless_exists"
          unless args[:_id].nil?
            request = org.elasticsearch.action.index.IndexRequest.new(args[:_index])
            request.id(args[:_id])
            request.routing(args[:_routing]) if args[:_routing]
            request.source(source)
            request.opType("create")
          else
            raise(LogStash::ConfigurationError, "Specifying action => 'create_unless_exists' without a document '_id' is not supported.")
          end
        when "update"
          unless args[:_id].nil?
            request = org.elasticsearch.action.update.UpdateRequest.new(args[:_index], args[:_type], args[:_id])
            request.routing(args[:_routing]) if args[:_routing]
            request.doc(source)
            if @client_options[:doc_as_upsert]
              request.docAsUpsert(true)
            else
              request.upsert(args[:_upsert]) if args[:_upsert]
            end
          else
            raise(LogStash::ConfigurationError, "Specifying action => 'update' without a document '_id' is not supported.")
          end
        else
          raise(LogStash::ConfigurationError, "action => '#{action_name}' is not currently supported.")
      end # case action

      request.type(args[:_type]) if args[:_type]
      return request
    end

    # def build_request

    def template_exists?(name)
      return !client.admin.indices.
        prepareGetTemplates(name).
        execute().
        actionGet().
        getIndexTemplates().
        isEmpty
    end

    def template_install(name, template, force=false)
      if template_exists?(name) && !force
        @logger.debug("Found existing Elasticsearch template. Skipping template management", :name => name)
        return
      end
      template_put(name, template)
    end

    def template_put(name, template)
      response = client.admin.indices.
        preparePutTemplate(name).
        setSource(LogStash::Json.dump(template)).
        execute().
        actionGet()

      raise "Could not index template!" unless response.isAcknowledged
    end
  end # class NodeClient

  class TransportClient < NodeClient
    private
    def make_client
      builder = org.elasticsearch.client.transport.TransportClient.builder()
      client = client_options[:elasticsearch_plugins].reduce(builder) do |b,plugin_class|
        b.add_plugin(plugin_class)
      end.settings((settings.build)).build()

      client_options[:hosts].each do |host|
        matches = host.match /([^:+]+)(:(\d+))?/

        inet_addr = java.net.InetAddress.getByName(matches[1])
        port = (matches[3] || 9300).to_i
        client.addTransportAddress(
          org.elasticsearch.common.transport.InetSocketTransportAddress.new(
            inet_addr, port
          )
        )
      end

      return client
    end

    # We want a separate client per instance for transport
    def client
      client_mutex_synchronize { @client ||= make_client }
    end

    def clear_client()
      client_mutex_synchronize { @client = nil }
    end
  end
end end end end