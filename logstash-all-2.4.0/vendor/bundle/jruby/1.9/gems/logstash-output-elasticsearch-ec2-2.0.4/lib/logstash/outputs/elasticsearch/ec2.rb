require 'logstash-output-elasticsearch-ec2_jars.rb'

module LogStash::Outputs::ElasticSearch::Ec2

  def self.included(base)
    base.extend(self)
    base.create_options
  end

  def create_options

    config :discovery, :validate => ['zen', 'ec2'], :default => 'zen'

    config :aws_access_key, :validate => :string

    config :aws_secret_key, :validate => :string

    config :aws_protocol, :validate => ['http', 'https'], :default => 'https'

    config :s3_protocol, :validate => ['http', 'https']

    config :ec2_protocol, :validate => ['http', 'https']

    config :aws_proxy_host, :validate => :string

    config :aws_proxy_port, :validate => :number

    config :aws_region, :validate => ['us-east-1', 'us-west-1', 'us-west-2', 'ap-southeast-1', 'ap-southeast-2', 'ap-northeast-1', 'eu-west-1', 'sa-east-1' ]

  end

  def self.create_client_config(plugin)
     settings = {}
     if plugin.discovery == 'ec2'
       settings['discovery.type'] = plugin.discovery
       settings['cloud.aws.access_key'] = plugin.aws_access_key if plugin.aws_access_key
       settings['cloud.aws.secret_key'] = plugin.aws_secret_key if plugin.aws_secret_key
       settings['cloud.aws.protocol'] = plugin.aws_protocol if plugin.aws_protocol
       settings['cloud.aws.protocol.s3.protocol'] = plugin.s3_protocol if plugin.s3_protocol
       settings['cloud.aws.protocol.ec2.protocol'] = plugin.ec2_protocol if plugin.ec2_protocol
       settings['cloud.aws.proxy_host'] = plugin.aws_proxy_host if plugin.aws_proxy_host
       settings['cloud.aws.proxy_port'] = plugin.aws_proxy_port if plugin.aws_proxy_port
       settings['cloud.aws.region'] = plugin.aws_region if plugin.aws_region
     end
     settings
  end

end

LogStash::Outputs::ElasticSearch.instance_eval{ include LogStash::Outputs::ElasticSearch::Ec2 }
