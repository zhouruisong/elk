# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"
require "zk"

# An output plugin that send data to zookeeper.
class LogStash::Outputs::Zookeeper < LogStash::Outputs::Base
  config_name "zookeeper"

  config :ip_list, :validate => :string, :default => "localhost:2181"
  
  config :path, :validate => :string, :default => "/logstash"

  config :data, :validate => :string, :default => "hello world"

  public
  def register
	@zk = ZK.new(@ip_list)

	if @zk.exists?(@path) == false
		@zk.create(@path, '')
	end
  end # def register

  public
  def receive(event)
	@zk.set(@path, @data)
  end # def event
end # class LogStash::Outputs::Zookeeper
