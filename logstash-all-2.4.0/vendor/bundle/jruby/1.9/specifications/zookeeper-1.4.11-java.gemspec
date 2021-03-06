# -*- encoding: utf-8 -*-
# stub: zookeeper 1.4.11 java lib java

Gem::Specification.new do |s|
  s.name = "zookeeper"
  s.version = "1.4.11"
  s.platform = "java"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib", "java"]
  s.authors = ["Phillip Pearson", "Eric Maland", "Evan Weaver", "Brian Wickman", "Neil Conway", "Jonathan D. Simms"]
  s.date = "2015-09-28"
  s.description = "A low-level multi-Ruby wrapper around the ZooKeeper API bindings. For a\nfriendlier interface, see http://github.com/slyphon/zk. Currently supported:\nMRI: {1.8.7, 1.9.2, 1.9.3}, JRuby: ~> 1.6.7, Rubinius: 2.0.testing, REE 1.8.7.\n\nThis library uses version 3.4.5 of zookeeper bindings.\n\n"
  s.email = ["slyphon@gmail.com"]
  s.homepage = "https://github.com/slyphon/zookeeper"
  s.rubygems_version = "2.4.8"
  s.summary = "Apache ZooKeeper driver for Rubies"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<slyphon-log4j>, ["= 1.2.15"])
      s.add_runtime_dependency(%q<slyphon-zookeeper_jar>, ["= 3.3.5"])
    else
      s.add_dependency(%q<slyphon-log4j>, ["= 1.2.15"])
      s.add_dependency(%q<slyphon-zookeeper_jar>, ["= 3.3.5"])
    end
  else
    s.add_dependency(%q<slyphon-log4j>, ["= 1.2.15"])
    s.add_dependency(%q<slyphon-zookeeper_jar>, ["= 3.3.5"])
  end
end
