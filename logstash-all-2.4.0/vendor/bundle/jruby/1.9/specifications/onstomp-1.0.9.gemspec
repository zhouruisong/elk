# -*- encoding: utf-8 -*-
# stub: onstomp 1.0.9 ruby lib

Gem::Specification.new do |s|
  s.name = "onstomp"
  s.version = "1.0.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Ian D. Eccles"]
  s.date = "2015-07-23"
  s.description = "Client library for message passing with brokers that support the Stomp protocol."
  s.email = ["ian.eccles@gmail.com"]
  s.homepage = "http://github.com/meadvillerb/onstomp"
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubyforge_project = "onstomp-core"
  s.rubygems_version = "2.4.8"
  s.summary = "Client for message queues implementing the Stomp protocol interface."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, ["~> 2.4.0"])
      s.add_development_dependency(%q<simplecov>, [">= 0.3.0"])
      s.add_development_dependency(%q<yard>, [">= 0.6.0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, ["~> 2.4.0"])
      s.add_dependency(%q<simplecov>, [">= 0.3.0"])
      s.add_dependency(%q<yard>, [">= 0.6.0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, ["~> 2.4.0"])
    s.add_dependency(%q<simplecov>, [">= 0.3.0"])
    s.add_dependency(%q<yard>, [">= 0.6.0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
