require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

# Default directory to look in is `/specs`
# Run with `rake spec`
RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = ['--color', '--format=d', '--format=Nc']
end

task :default => :spec

task :console do
  exec "irb -r arthur -I ./lib"
end

task :c => :console
