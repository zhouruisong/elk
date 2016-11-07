# -*- encoding: utf-8 -*-
# stub: logstash-output-monasca_log_api 0.5.2 ruby lib

Gem::Specification.new do |s|
  s.name = "logstash-output-monasca_log_api"
  s.version = "0.5.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.metadata = { "logstash_group" => "output", "logstash_plugin" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib"]
  s.authors = ["Fujitsu Enabling Software Technology GmbH"]
  s.date = "2016-08-24"
  s.description = "This gem is a logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/plugin install gemname. This gem is not a stand-alone program"
  s.email = "kamil.choroba@est.fujitsu.com,tomasz.trebski@ts.fujitsu.com"
  s.homepage = "https://github.com/FujitsuEnablingSoftwareTechnologyGmbH/logstash-output-monasca_api"
  s.licenses = ["Apache-2.0"]
  s.rubygems_version = "2.4.8"
  s.summary = "This gem is a logstash output plugin to connect via http to monasca-log-api."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<logstash-core>, ["~> 2.0"])
      s.add_runtime_dependency(%q<logstash-codec-plain>, ["~> 2.0"])
      s.add_runtime_dependency(%q<logstash-codec-json>, ["~> 2.0"])
      s.add_runtime_dependency(%q<vine>, ["~> 0.2"])
      s.add_development_dependency(%q<logstash-devutils>, ["~> 0.0.14"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.10"])
      s.add_development_dependency(%q<rubocop>, ["~> 0.37.2"])
      s.add_development_dependency(%q<webmock>, ["~> 2.0"])
    else
      s.add_dependency(%q<logstash-core>, ["~> 2.0"])
      s.add_dependency(%q<logstash-codec-plain>, ["~> 2.0"])
      s.add_dependency(%q<logstash-codec-json>, ["~> 2.0"])
      s.add_dependency(%q<vine>, ["~> 0.2"])
      s.add_dependency(%q<logstash-devutils>, ["~> 0.0.14"])
      s.add_dependency(%q<simplecov>, ["~> 0.10"])
      s.add_dependency(%q<rubocop>, ["~> 0.37.2"])
      s.add_dependency(%q<webmock>, ["~> 2.0"])
    end
  else
    s.add_dependency(%q<logstash-core>, ["~> 2.0"])
    s.add_dependency(%q<logstash-codec-plain>, ["~> 2.0"])
    s.add_dependency(%q<logstash-codec-json>, ["~> 2.0"])
    s.add_dependency(%q<vine>, ["~> 0.2"])
    s.add_dependency(%q<logstash-devutils>, ["~> 0.0.14"])
    s.add_dependency(%q<simplecov>, ["~> 0.10"])
    s.add_dependency(%q<rubocop>, ["~> 0.37.2"])
    s.add_dependency(%q<webmock>, ["~> 2.0"])
  end
end
