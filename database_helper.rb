# database_helper.rb
require 'mongo'

class DatabaseHelper

	def connection
		@connection ||= "mongodb+srv://admin:123@cluster0.zcrcf.mongodb.net/RubyDatabase?retryWrites=true&w=majority"
	end

	def client
		@client ||= Mongo::Client.new(connection)
	end

	def database
		client.database
	end

	def collection name
		database.collection(name) || database.create_collection(name)
	end		

	def close
		client.close unless client.nil?
	end

	# def clear_collection name
	# 	collection(name).collection.delete_many({})
	# end

	# def teardown
	# 	client.database.drop
	# end

end