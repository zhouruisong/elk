# -*- encoding: utf-8 -*-
# stub: zabbix_protocol 0.1.5 ruby lib

Gem::Specification.new do |s|
  s.name = "zabbix_protocol"
  s.version = "0.1.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Genki Sugawara"]
  s.date = "2016-04-28"
  s.description = "Zabbix protocols builder/parser."
  s.email = ["sgwr_dts@yahoo.co.jp"]
  s.homepage = "https://github.com/winebarrel/zabbix_protocol"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "Zabbix protocols builder/parser."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<multi_json>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 3.0.0"])
    else
      s.add_dependency(%q<multi_json>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 3.0.0"])
    end
  else
    s.add_dependency(%q<multi_json>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 3.0.0"])
  end
end
