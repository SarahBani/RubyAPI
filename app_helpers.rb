# app_helpers.ru

require_relative './helper_module.rb'

class App < Sinatra::Base

	helpers do

		def check_id_valid id
			id.nil? || Integer(id) rescue halt HTTPStatus::BadRequest	
		end	

		def check_content_type_valid
			halt HTTPStatus::UnsupportedMediaType unless request.env['CONTENT_TYPE'] == Constants::JsonContentType
		end
		
		def send_data(data = {})
			data[:json].call.to_json if data[:json]
	    end

		def get_data 
			begin
		  		data = JSON.parse(request.body.read)
		  		halt HTTPStatus::BadRequest unless HelperModule.has_value?(data)
		  		data
			rescue JSON::ParserError => e
				halt HTTPStatus::BadRequest, send_data(json: -> { { message: e.to_s } })
			end
		end
		
	end		
end		