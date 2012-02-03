# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "renee/version"

Gem::Specification.new do |s|
  s.name        = "renee-session"
  s.version     = Renee::VERSION
  s.authors     = ["Josh Hull"]
  s.email       = ["joshbuddy@gmail.com"]
  s.homepage    = "http://reneerb.com"
  s.summary     = %q{The super-friendly web framework session component}
  s.description = %q{The super-friendly web framework session component.}

  s.rubyforge_project = "renee-session"

  s.files         = `git ls-files -- lib/renee/session*`.split("\n")
  s.test_files    = `git ls-files -- test/renee-session/*`.split("\n") + ["test/test_helper.rb"]
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'rack', "~> 1.3.0"
  s.add_runtime_dependency 'renee-core', "#{Renee::VERSION}"

  s.add_development_dependency 'minitest', "~> 2.11.1"
  s.add_development_dependency 'rake'
  s.add_development_dependency 'bundler'
  s.add_development_dependency "rack-test", ">= 0.5.0"
  s.add_development_dependency "haml", ">= 2.2.0"
end
