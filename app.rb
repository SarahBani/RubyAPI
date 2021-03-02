# app.rb
require 'sinatra'
require 'json'

require_relative './app_helpers.rb'
require_relative './repository.rb'
require_relative './cache.rb'
require_relative './http_status.rb'
require_relative './constants.rb'

class App < Sinatra::Base	

	before do
		content_type Constants::JsonContentType
		# Geokit::default_units = :meters
	end

	get '/' do
	    Constants::RuntasticWelcome
	end

	get '/traces/:id' do |id|	
		check_id_valid id	

		data = Cache.fetch id do 			
			 Repository.select_item id
		end	

		case 
			when data == Constants::DatabaseError
			  	halt HTTPStatus::InternalServerError
			when data.nil?
			  	halt HTTPStatus::NotFound
		  	else	  
		  		data.to_json
		end
	end

	post '/traces' do
		check_content_type_valid	
		data = get_data	
		id =  Repository.insert data
		if id == Constants::DatabaseError || id.nil?
			halt HTTPStatus::InternalServerError
		else
			url = "/#{id}"
			response.headers[Constants::HeaderLocation] = url   
			status HTTPStatus::Created
		end		
	end

	put '/traces/:id' do |id|
		check_content_type_valid
		check_id_valid id
		data = get_data	
		result = Repository.update id, data
		case 
			when result == Constants::DatabaseError		
			  	halt HTTPStatus::InternalServerError
			when result.nil?
			  	halt HTTPStatus::InternalServerError
			when result.is_a?(Numeric) && result.zero?
		  	 	halt HTTPStatus::NotFound
		  	else
				Cache.remove(id)
		  		status HTTPStatus::NoContent	
		end	
	end

	delete '/traces/:id' do |id|
		check_id_valid id
		result = Repository.delete id
		case 
			when result == Constants::DatabaseError		
			  	halt HTTPStatus::InternalServerError
			when result.nil?
			  	halt HTTPStatus::InternalServerError
			when result.is_a?(Numeric) && result.zero?
		  	 	halt HTTPStatus::NotFound
	  	 	else
				Cache.remove(id)
				status HTTPStatus::OK	
		end
	end

end
