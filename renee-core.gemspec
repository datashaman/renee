# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "renee/version"

Gem::Specification.new do |s|
  s.name        = "renee-core"
  s.version     = Renee::VERSION
  s.authors     = ["Josh Hull", "Nathan Esquenazi", "Arthur Chiu"]
  s.email       = ["joshbuddy@gmail.com", "nesquena@gmail.com", "mr.arthur.chiu@gmail.com"]
  s.homepage    = "http://reneerb.com"
  s.summary     = %q{The super-friendly rack helpers}
  s.description = %q{The super-friendly rack helpers.}

  s.rubyforge_project = "renee"

  s.files         = `git ls-files -- lib/renee/core/*`.split("\n")
  s.test_files    = `git ls-files -- test/renee-core/*`.split("\n") + ["test/test_helper.rb"]
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'rack', "~> 1.3.0"

  s.add_development_dependency 'minitest', "~> 2.6.1"
  s.add_development_dependency 'bundler'
  s.add_development_dependency "rack-test", ">= 0.5.0"
  s.add_development_dependency "rake", "0.8.7"
end
