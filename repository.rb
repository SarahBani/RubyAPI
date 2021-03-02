# repository.rb
require 'mongo'

require_relative './database_helper.rb'
require_relative './helper_module.rb'
require_relative './constants.rb'

# Turn off debug-mode
Mongo::Logger.logger.level = Logger::WARN

class Repository	

	@@database_helper ||= DatabaseHelper.new 

	private_class_method def self.collection_name
	 	"#{HelperModule.is_test_environment? ? 'test_' : ''}traces"
	end

	private_class_method def self.collection
		@@database_helper.collection collection_name
	end
	
	private_class_method def self.max_id
		result = collection.find({}, { 'projection' =>  { '_id' => 1 } } ).sort({"_id" => -1}).limit(1).first()
		unless (result.nil?)
			result["_id"]
		else	
			0
		end
	end

	def self.select_item id
		begin	
			puts '---fetch from database---'	
			result = collection.find({_id: id.to_i },{ 'projection' =>  { '_id' => 0 } }).first()
			result["locations"] unless result.nil?
		rescue StandardError => err
			puts(Constants::ErrorTitle + "#{err}")
			Constants::DatabaseError
		ensure
			@@database_helper.close
		end	
	end

	def self.insert data
		begin 	
			puts '---insert into database---'	
			id = max_id() + 1
			doc = 
			{
				_id: id,
			    locations: data
			}
			result = collection.insert_one(doc)	
			if (result.n == 1) # returns 1 when one document was inserted	
				id
			end
		rescue StandardError => err
			puts(Constants::ErrorTitle + "#{err}")
			Constants::DatabaseError
		ensure
			@@database_helper.close
		end	
	end
	
	def self.update id, data	
		begin		
			puts '---update data in database---'		
			result = collection.update_one({ _id: id.to_i }, { "$set": { locations: data } })	
			result.n # returns id when one document was inserted, returns 0 when id not exists
		rescue StandardError => err
			puts(Constants::ErrorTitle + "#{err}")
			Constants::DatabaseError
		ensure			
			@@database_helper.close
		end	
	end
	
	def self.delete id
		begin			
			puts '---delete data from database---'			
			result = collection.delete_one({ _id: id.to_i })
			result.n # returns 1 when one document was updated, returns 0 when id not exists
		rescue StandardError => err
			puts(Constants::ErrorTitle + "#{err}")
			Constants::DatabaseError
		ensure
			@@database_helper.close
		end	
	
	end  

 	def self.finalize
     	if HelperModule.is_test_environment?
			result = collection.delete_many({})
			result.n
		end
  	end           

end