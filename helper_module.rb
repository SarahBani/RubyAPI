# helper_module.rb

require_relative './constants.rb'

module HelperModule

	def self.is_test_environment?
		ENV[Constants::App_Environment] == Constants::App_Environment_Test
	end 

	def self.is_float? value
		# Float(value, exception: false)
		true if Float(value) rescue false
	end

	def self.is_trace_valid? trace
		if has_value?(trace) && !trace.kind_of?(Array) && !trace[Constants::Latitude].nil? && !trace[Constants::Longitude].nil? 
			latitude = trace[Constants::Latitude]
			longitude = trace[Constants::Longitude]
			if is_float?(latitude) && is_float?(longitude)	
				true
			end
		else
			false
		end
	end

	def self.has_value? data
		!(data.nil? || data == [] || data == [''] || data == {})
	end

end