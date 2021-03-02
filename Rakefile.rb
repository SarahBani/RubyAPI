# Rakefile.rb
require 'rake'
require 'rake/testtask'
require 'rspec/core/rake_task'

require_relative './app'

# Rake::TestTask.new do |t|
#   t.pattern = "spec/**/*_spec.rb"
# end

# RSpec::Core::RakeTask.new(:spec)
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "spec/**/*_spec.rb"
end

# task default: :test
task :default => :spec