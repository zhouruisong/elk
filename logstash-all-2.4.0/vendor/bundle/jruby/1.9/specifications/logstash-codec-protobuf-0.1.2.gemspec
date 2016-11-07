# -*- encoding: utf-8 -*-
# stub: logstash-codec-protobuf 0.1.2 ruby lib

Gem::Specification.new do |s|
  s.name = "logstash-codec-protobuf"
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.metadata = { "logstash_group" => "codec", "logstash_plugin" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib"]
  s.authors = ["Inga Feick"]
  s.date = "2016-04-22"
  s.description = "This gem is a logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/plugin install gemname. This gem is not a stand-alone program"
  s.email = "inga.feick@trivago.com"
  s.licenses = ["Apache License (2.0)"]
  s.rubygems_version = "2.4.8"
  s.summary = "This codec may be used to decode (via inputs) and encode (via outputs) protobuf messages"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<logstash-core>, ["< 3.0.0", ">= 1.4.0"])
      s.add_runtime_dependency(%q<ruby-protocol-buffers>, [">= 0"])
      s.add_development_dependency(%q<logstash-devutils>, [">= 0"])
    else
      s.add_dependency(%q<logstash-core>, ["< 3.0.0", ">= 1.4.0"])
      s.add_dependency(%q<ruby-protocol-buffers>, [">= 0"])
      s.add_dependency(%q<logstash-devutils>, [">= 0"])
    end
  else
    s.add_dependency(%q<logstash-core>, ["< 3.0.0", ">= 1.4.0"])
    s.add_dependency(%q<ruby-protocol-buffers>, [">= 0"])
    s.add_dependency(%q<logstash-devutils>, [">= 0"])
  end
end
