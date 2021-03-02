# spec/spec_helper.rb
require 'rack/test'
require 'rspec'
require "rspec/mocks/standalone"
require 'loc'
require "rest-client"

require '../app'

ENV[Constants::App_Environment] ||= Constants::App_Environment_Test

RSpec.configure do |config|
	config.include Rack::Test::Methods

	# config.filter_run :focus => true
	# config.filter_run_when_matching :focus

	# config.order = 'random'
end