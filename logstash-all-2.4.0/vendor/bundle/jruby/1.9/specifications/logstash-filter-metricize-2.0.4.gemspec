# -*- encoding: utf-8 -*-
# stub: logstash-filter-metricize 2.0.4 ruby lib

Gem::Specification.new do |s|
  s.name = "logstash-filter-metricize"
  s.version = "2.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.metadata = { "group" => "filter", "logstash_plugin" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib"]
  s.authors = ["Elastic"]
  s.date = "2016-03-24"
  s.description = "Metricize will take an event together with a list of metric fields and split this into multiple events, each holding a single metric."
  s.email = "christian.dahlqvist@elastic.co"
  s.homepage = "http://logstash.net/"
  s.licenses = ["Apache License (2.0)"]
  s.rubygems_version = "2.4.8"
  s.summary = "The metricize filter is for transforming events with multiple metrics into multiple event each with a single metric."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<logstash-core-plugin-api>, ["~> 1.0"])
      s.add_development_dependency(%q<logstash-devutils>, [">= 0"])
    else
      s.add_dependency(%q<logstash-core-plugin-api>, ["~> 1.0"])
      s.add_dependency(%q<logstash-devutils>, [">= 0"])
    end
  else
    s.add_dependency(%q<logstash-core-plugin-api>, ["~> 1.0"])
    s.add_dependency(%q<logstash-devutils>, [">= 0"])
  end
end
