# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "renee/version"

Gem::Specification.new do |s|
  s.name        = "renee-streaming"
  s.version     = Renee::VERSION
  s.authors     = ["Josh Hull", "Brad Gessler"]
  s.email       = ["joshbuddy@gmail.com", "brad@bradgessler.com"]
  s.homepage    = "http://reneerb.com"
  s.summary     = %q{The super-friendly rack helpers -- for streaming!}
  s.description = %q{The super-friendly rack helpers -- for streaming!!}

  s.rubyforge_project = "renee-streaming"

  s.files         = `git ls-files -- lib/renee/streaming*`.split("\n")
  s.test_files    = `git ls-files -- test/renee-streaming/*`.split("\n") + ["test/test_helper.rb"]
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'rack', "~> 1.3.0"
  s.add_runtime_dependency 'renee-core', "#{Renee::VERSION}"

  s.add_development_dependency 'minitest', "~> 2.6.1"
  s.add_development_dependency 'bundler'
  s.add_development_dependency "rack-test", ">= 0.5.0"
  s.add_development_dependency "rake"
end
