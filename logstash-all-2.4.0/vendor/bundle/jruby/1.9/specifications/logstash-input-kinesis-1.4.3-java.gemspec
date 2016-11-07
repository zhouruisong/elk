# -*- encoding: utf-8 -*-
# stub: logstash-input-kinesis 1.4.3 java lib

Gem::Specification.new do |s|
  s.name = "logstash-input-kinesis"
  s.version = "1.4.3"
  s.platform = "java"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.metadata = { "logstash_group" => "input", "logstash_plugin" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib"]
  s.authors = ["Brian Palmer"]
  s.date = "2016-02-08"
  s.description = "This gem is a logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/plugin install gemname. This gem is not a stand-alone program"
  s.email = ["brian@codekitchen.net"]
  s.homepage = "https://github.com/codekitchen/logstash-input-kinesis"
  s.licenses = ["Apache License (2.0)"]
  s.rubygems_version = "2.4.8"
  s.summary = "Logstash plugin for Kinesis input"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.7"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<rspec>, ["~> 3.2.0"])
      s.add_development_dependency(%q<logstash-core>, [">= 1.5.1"])
      s.add_development_dependency(%q<logstash-codec-json>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.7"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<rspec>, ["~> 3.2.0"])
      s.add_dependency(%q<logstash-core>, [">= 1.5.1"])
      s.add_dependency(%q<logstash-codec-json>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.7"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<rspec>, ["~> 3.2.0"])
    s.add_dependency(%q<logstash-core>, [">= 1.5.1"])
    s.add_dependency(%q<logstash-codec-json>, [">= 0"])
  end
end
