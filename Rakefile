require 'rake/testtask'

ROOT = File.expand_path(File.dirname(__FILE__))

task :default => :test

def lsh(cmd, &block)
  out, code = lsh_with_code(cmd, &block)
  code == 0 ? out : raise(out.empty? ? "Running `#{cmd}' failed. Run this command directly for more detailed output." : out)
end

def lsh_with_code(cmd, &block)
  cmd << " 2>&1"
  outbuf = ''
  outbuf = `#{cmd}`
  if $? == 0
    block.call(outbuf) if block
  end
  [outbuf, $?]
end

renee_gems = %w[
  renee-core
  renee-render
  renee-streaming
  renee
].freeze

desc "build #{renee_gems.join(', ')} gems"
task :build do
  renee_gems.each do |g|
    lsh "mkdir -p pkg && gem build #{g}.gemspec && mv *.gem pkg"
    puts "#{g} built"
  end
end

task :release => [:build, :doc] do
  require File.join(ROOT, 'renee', 'lib', 'renee', 'version')
  version_tag = "v#{Renee::VERSION}"
  begin
    raise("#{version_tag} has already been committed") if lsh('git tag').split(/\n/).include?(version_tag)
    sh "git tag #{version_tag}"
    puts "adding tag #{version_tag}"
    renee_gems.each do |g|
      sh "gem push pkg/#{g}-#{Renee::VERSION}.gem"
      puts "#{g} pushed"
    end
    sh "git push"
    sh "git push --tags"
  rescue
    puts "something went wrong"
    sh "git tag -d #{version_tag}"
    raise
  end
end

task :install => :build do
  require File.join(ROOT, 'lib', 'renee', 'version')
  renee_ge/ms.each do |g|
    lsh "gem install pkg/#{g}-#{Renee::VERSION}.gem"
    puts "#{g} installed"
  end
end

task :bundle do
  renee_gems.each do |g|
    sh "env BUNDLE_GEMFILE=Gemfile-#{g} bundle"
  end
end

renee_gems_tasks = Hash[renee_gems.map{|rg| [rg, :"test_#{rg.gsub('-', '_')}"]}].freeze

desc "Run tests for all renee stack gems"
task :test do
  renee_gems_tasks.values.each do |task|
    Rake::Task[task].invoke
  end
end

renee_gems_tasks.each do |g, tn|
  desc "Run tests for #{g} (shell out)"
  task tn do
    sh "env BUNDLE_GEMFILE=Gemfile-#{g} bundle exec rake test-#{g}"
  end

  Rake::TestTask.new("test-#{g}") do |t|
    t.libs.push "lib"
    t.test_files = FileList[File.expand_path("../test/#{g}/**/*_test.rb", __FILE__)]
    t.verbose = true
  end
end

desc "Generate YARD documentation"
task :'yard' do
  require 'yard'
  Dir['*.gemspec'].to_a.each do |gemspec|
    spec = Gem::Specification.load(gemspec)
    puts "spec #{spec.inspect}"
    task_name = :"yard:#{spec.name}"
    rb_files = spec.files.select{|f| f[/^lib/]}
    readme = spec.name == 'renee' ? "README.md" : "README-#{spec.name}.md"
    pid = fork do # yard has some shared state somewhere. poor poor yard.
      YARD::Rake::YardocTask.new do |t|
        t.options = ['-o', File.expand_path("../../renee-site/public/docs/#{spec.name}", __FILE__), '--readme', readme, '--no-private', '--markup', 'markdown']
        t.files   = rb_files
      end
      Rake::Task[:yard].execute
    end
    _, status = Process.waitpid2(pid)
    raise unless status.success?
  end
end

#
#
#desc "Generate documentation for the renee framework"
#task :doc do
#  [:render, :core].each do |name|
#    
#    --output-dir doc/
#    --readme README.md
#    --no-private
#    --title Renee Framework
#    --markup markdown
#    'renee/lib/**/*.rb'
#    'renee-*/lib/**/*.rb'
#  end
#end
#