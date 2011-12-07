# -*- encoding: utf-8 -*-
$:.push File.expand_path("../../renee-core/lib", __FILE__)
require "renee_core/version"

Gem::Specification.new do |s|
  s.name        = "renee-bindings"
  s.version     = Renee::Core::VERSION
  s.authors     = ["Josh Hull", "Nathan Esquenazi", "Arthur Chiu"]
  s.email       = ["joshbuddy@gmail.com", "nesquena@gmail.com", "mr.arthur.chiu@gmail.com"]
  s.homepage    = "http://reneerb.com"
  s.summary     = %q{The super-friendly web framework data binding component}
  s.description = %q{The super-friendly web framework data binding component.}

  s.rubyforge_project = "renee-bindings"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'renee-core', "#{Renee::Core::VERSION}"

  s.add_dependency "multi_json", "~> 1.0.4"

  s.add_development_dependency 'minitest', "~> 2.6.1"
  s.add_development_dependency 'rake'
  s.add_development_dependency 'bundler'
end
