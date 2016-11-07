# -*- encoding: utf-8 -*-
# stub: ceph-ruby-ffi19 1.3 ruby lib

Gem::Specification.new do |s|
  s.name = "ceph-ruby-ffi19"
  s.version = "1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Netskin GmbH", "Corin Langosch"]
  s.date = "2016-02-01"
  s.description = "Easy management of Ceph"
  s.email = ["info@netskin.com", "info@corinlangosch.com"]
  s.homepage = "https://github.com/ceph/ceph-ruby"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "Easy management of Ceph Distributed Storage System using ruby"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ffi>, ["~> 1.9.10"])
      s.add_runtime_dependency(%q<activesupport>, [">= 3.0.0"])
    else
      s.add_dependency(%q<ffi>, ["~> 1.9.10"])
      s.add_dependency(%q<activesupport>, [">= 3.0.0"])
    end
  else
    s.add_dependency(%q<ffi>, ["~> 1.9.10"])
    s.add_dependency(%q<activesupport>, [">= 3.0.0"])
  end
end
