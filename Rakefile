require 'rake/testtask'
require 'bundler/gem_tasks'
require 'yard'

ROOT = File.expand_path(File.dirname(__FILE__))

task :default => :test

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.test_files = FileList[File.expand_path("../test/**/*_test.rb", __FILE__)]
  t.verbose = true
end

YARD::Rake::YardocTask.new do |t|
  t.options = [
    '-o', File.expand_path("../site/public/docs/core", __FILE__),
    '--readme', 'README.md',
    '--no-private',
    '--markup', 'markdown'
  ]
  t.files   = 'lib/**/*.rb'
end
