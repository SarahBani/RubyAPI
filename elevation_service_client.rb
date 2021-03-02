# elevation_service_client.rb
require "json"
require "rest-client"

require_relative './helper_module.rb'

class ElevationServiceClient

	private

	def self.single_url
		@single_url ||= 'https://codingcontest.runtastic.com/api/elevations/'
	end

	def self.bulk_url
		@bulk_url ||= 'https://codingcontest.runtastic.com/api/elevations/bulk'
	end

	public

	def self.get_elevations_single trace
		if HelperModule.is_trace_valid? trace
			begin
				response = RestClient::Request.new(
				   :method => :get,
				   :url => "#{single_url}#{trace['latitude']}/#{trace['longitude']}",
				   :verify_ssl => false
				).execute	
				Integer(response) # to make sure the response is an integer number
				response
			rescue
				nil
			end
		end
	end

	def self.get_elevations_bulk traces
		begin
			response = RestClient::Request.new(
			   :method => :post,
			   :url => bulk_url,
			   :verify_ssl => false,
			   :headers => {content_type: 'application/json'},
			   :payload => traces.to_json
			).execute
			JSON.parse(response.to_str)
		rescue => err
			nil
		end
	end

end	