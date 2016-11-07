# -*- encoding: utf-8 -*-
# stub: restforce 2.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "restforce"
  s.version = "2.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Eric J. Holmes", "Tim Rogers"]
  s.date = "2016-07-29"
  s.description = "A lightweight ruby client for the Salesforce REST API."
  s.email = ["eric@ejholmes.net", "tim@gocardless.com"]
  s.homepage = "http://restforce.org/"
  s.licenses = ["MIT"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.rubygems_version = "2.4.8"
  s.summary = "A lightweight ruby client for the Salesforce REST API."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<faraday>, ["~> 0.9.0"])
      s.add_runtime_dependency(%q<faraday_middleware>, [">= 0.8.8"])
      s.add_runtime_dependency(%q<json>, ["< 1.9.0", ">= 1.7.5"])
      s.add_runtime_dependency(%q<hashie>, ["< 4.0", ">= 1.2.0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.14.0"])
      s.add_development_dependency(%q<webmock>, ["~> 1.13.0"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.7.1"])
      s.add_development_dependency(%q<rubocop>, ["~> 0.31.0"])
      s.add_development_dependency(%q<faye>, [">= 0"])
    else
      s.add_dependency(%q<faraday>, ["~> 0.9.0"])
      s.add_dependency(%q<faraday_middleware>, [">= 0.8.8"])
      s.add_dependency(%q<json>, ["< 1.9.0", ">= 1.7.5"])
      s.add_dependency(%q<hashie>, ["< 4.0", ">= 1.2.0"])
      s.add_dependency(%q<rspec>, ["~> 2.14.0"])
      s.add_dependency(%q<webmock>, ["~> 1.13.0"])
      s.add_dependency(%q<simplecov>, ["~> 0.7.1"])
      s.add_dependency(%q<rubocop>, ["~> 0.31.0"])
      s.add_dependency(%q<faye>, [">= 0"])
    end
  else
    s.add_dependency(%q<faraday>, ["~> 0.9.0"])
    s.add_dependency(%q<faraday_middleware>, [">= 0.8.8"])
    s.add_dependency(%q<json>, ["< 1.9.0", ">= 1.7.5"])
    s.add_dependency(%q<hashie>, ["< 4.0", ">= 1.2.0"])
    s.add_dependency(%q<rspec>, ["~> 2.14.0"])
    s.add_dependency(%q<webmock>, ["~> 1.13.0"])
    s.add_dependency(%q<simplecov>, ["~> 0.7.1"])
    s.add_dependency(%q<rubocop>, ["~> 0.31.0"])
    s.add_dependency(%q<faye>, [">= 0"])
  end
end
