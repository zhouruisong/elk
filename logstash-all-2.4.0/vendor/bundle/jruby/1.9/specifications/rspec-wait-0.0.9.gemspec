# -*- encoding: utf-8 -*-
# stub: rspec-wait 0.0.9 ruby lib

Gem::Specification.new do |s|
  s.name = "rspec-wait"
  s.version = "0.0.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Steve Richert"]
  s.date = "2016-07-11"
  s.description = "Wait for conditions in RSpec"
  s.email = "steve.richert@gmail.com"
  s.homepage = "https://github.com/laserlemon/rspec-wait"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "Wait for conditions in RSpec"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rspec>, ["< 4", ">= 3"])
      s.add_development_dependency(%q<bundler>, ["~> 1.12"])
      s.add_development_dependency(%q<rake>, ["~> 11.2"])
    else
      s.add_dependency(%q<rspec>, ["< 4", ">= 3"])
      s.add_dependency(%q<bundler>, ["~> 1.12"])
      s.add_dependency(%q<rake>, ["~> 11.2"])
    end
  else
    s.add_dependency(%q<rspec>, ["< 4", ">= 3"])
    s.add_dependency(%q<bundler>, ["~> 1.12"])
    s.add_dependency(%q<rake>, ["~> 11.2"])
  end
end
