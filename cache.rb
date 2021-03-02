# cache.ru
require 'redis'
require 'loc'

require_relative './helper_module.rb'
require_relative './elevation_service_client.rb'

class Cache

	private_class_method def self.host
		@host ||= 'localhost'
	end

	private_class_method def self.post_no
		@post_no ||= 6379
	end

	private_class_method def self.expiration
		@expiration ||= 3600 * 24 * 5
	end

	private_class_method def self.database_number 
		# use the database number 15 when testing, otherwise use number 0
		@database_number ||= HelperModule.is_test_environment? ? 15 : 0
	end	

	private_class_method def self.database	
		Redis.new(:host => host, :port => post_no, :db => database_number)
  	end

	private_class_method def self.set_expiration key
		database.expire(key, expiration)
	end

	private_class_method def self.set_attributes data
		if data.kind_of?(Array)	
			set_distances data	
			set_elevations data	
		end
	end

	private_class_method def self.set_distances data	
		@@pre_location = nil
		@@distance = 0
  		data.each do |trace|
  			set_distance trace  			
		end
	end

	private_class_method def self.set_distance trace
		if HelperModule.is_trace_valid? trace			
			location = Loc::Location[trace[Constants::Latitude], trace[Constants::Longitude]]	
			calculate_distance location
			trace['distance'] =  @@distance.to_i
		end
	end

	private_class_method def self.calculate_distance current_location		
		unless @@pre_location.nil?
			@@distance += @@pre_location.distance_to(current_location)	
		end		
		@@pre_location = current_location
	end

	private_class_method def self.set_elevations data	
		elevations = ElevationServiceClient.get_elevations_bulk data
		if elevations&.length() == data.length()	
			for i in 0..data.length() - 1 do
			 	data[i]['elevation'] = elevations[i]
			end
		end
	end
	 
	def self.fetch key, &block	
		unless exists key
			data = block.call
			unless data.nil?			
				set_attributes data
				puts '---insert into cache---'	
				database.set(key, data.to_json)
			end
		else		
			puts '---fetch from cache---'			
			data =  JSON.parse(database.get(key))	
		end	
		set_expiration key
		data
	end

	def self.remove key  
		if exists key
			puts '---delete from cache---'	
			database.del(key)
		end
	end

	def self.exists key
		!(database&.get(key).nil? || database.get(key).empty?)
	end

	def self.clear 
     	if HelperModule.is_test_environment?
	  		database.flushall
		end
	end

	def self.close 
	  	database.quit
	end
  
end