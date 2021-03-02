# spec/app_spec.rb
require './spec_helper'

RSpec.describe App do

	before (:all) do
		puts '------------Start Testing App------------'
	end

	after (:all) do
		puts '------------End Testing App--------------'
	end

	# def app
	# 	App
	# end

  	let(:app) { App }
	let(:id) { 8 }
	let(:not_exists_id) { -1 }
	let(:invalid_id) { 'sss' }
  	let(:data) {[
			{ "latitude": 32.9377784729004, "longitude": -117.230392456055},
			{ "latitude": 32.937801361084, "longitude": -117.230323791504},
			{ "latitude": 32.9378204345703, "longitude": -117.230278015137}
		]}
	let(:formatted_data) { JSON.parse(data.to_json) }

	let(:invalid_data) {[
		{ "latitude": 32.9377784729004, "longitude": -117.230392456055 },
		{ "latitude": 32.937801361084},
		{ "latitude": 32.937801361084, "longitude": -117.230323791504 },
		{ "name": 32.937801361084},		
		{ "latitude": 32.9378204345703, "longitude": -117.230278015137 },	
		{ "latitude": 32978.20445703, "longitude": -1174.2}, # invalid lat & long
		{ "latitude": 32.9378204345703, "longitude": -117.230239868164 }
	]}
	let(:formatted_invalid_data) { JSON.parse(invalid_data.to_json) }

	let(:empty_string_data_array) {[""]}
	let(:empty_string_data_array2) {['']}
	let(:empty_data_array) {[]}
	let(:empty_data_object) {{}}
    let(:cache) { Cache }
    let(:repository) { Repository }

	describe "GET /:" do
		it "returns Runtastic Ruby Web API" do
			get "/"
			expect(last_response.body).to eq(Constants::RuntasticWelcome)
			expect(last_response.status).to eq HTTPStatus::OK
		end

		it "without / returns Runtastic Ruby Web API" do
			get ""
			expect(last_response.body).to eq(Constants::RuntasticWelcome)
			expect(last_response.status).to eq HTTPStatus::OK
		end
	end

	describe "GET traces/id:" do  

		context "Valid Request:" do
			
		  	let(:data_with_attributes) {[
					{ "latitude": 32.9377784729004, "longitude": -117.230392456055, "distance": 0, "elevation": 4139},
					{ "latitude": 32.937801361084, "longitude": -117.230323791504, "distance": 6, "elevation": 4139},
					{ "latitude": 32.9378204345703, "longitude": -117.230278015137, "distance": 11, "elevation": 4139}
				]}
			let(:formatted_data_with_attributes) { JSON.parse(data_with_attributes.to_json) }

			it "valid id should return OK json data with attributes" do
				# expect(repository).to receive(:select_item).with(anything).and_return(data)
			  	expect(cache).to receive(:fetch).with(id.to_s) do |&block|
		      		formatted_data_with_attributes
			    end
				get "/traces/#{id}"		
				expect(last_response.body).to eq(formatted_data_with_attributes.to_json)
				expect(last_response.status).to eq HTTPStatus::OK
			end	

		end

		context "Invalid Request:" do
			it "url postfixed / should return Not Found" do
				get "/traces/#{id}/"	
				expect(last_response.status).to eq HTTPStatus::NotFound
			end

			it "not exists id should return Not Found" do
				# expect(repository).to receive(:select_item).with('-1').and_return(nil)				
			  	expect(cache).to receive(:fetch).with(not_exists_id.to_s) do |&block|
			    	nil
			    end
				get "/traces/#{not_exists_id}"				
				expect(last_response.status).to eq HTTPStatus::NotFound
			end

			it "invalid id should return Bad Request" do
				get "/traces/#{invalid_id}"			
				expect(last_response.status).to eq HTTPStatus::BadRequest
			end

			it "no id should return Not Found" do
				get "/traces/"			
				expect(last_response.status).to eq HTTPStatus::NotFound
			end

			it "no /id should return Not Found" do
				get "/traces"			
				expect(last_response.status).to eq HTTPStatus::NotFound
			end

			it "wrong url returns Not Found" do
				get "/tracesss/#{id}"	
				expect(last_response.status).to eq HTTPStatus::NotFound	
			end
		end

		context "Database Exception:" do
			it "database raises error should return Internal Server Error" do
			  	expect(cache).to receive(:fetch).with(id.to_s) do |&block|
		      		Constants::DatabaseError
			    end
				get "/traces/#{id}"		
				expect(last_response.status).to eq HTTPStatus::InternalServerError
			end
		end
	end

	describe "POST traces:" do
		context "Valid Request:" do
			it "valid data should return Created" do
				expect(repository).to receive(:insert).with(formatted_data).and_return(id)
				post '/traces', data.to_json, {'CONTENT_TYPE' => Constants::JsonContentType}
				expected_header = "/#{id}"
				expect(last_response.status).to eq HTTPStatus::Created
				expect(last_response.headers["Location"]).to eq expected_header
			end

			it "data with some invalid items should return Created" do
				expect(repository).to receive(:insert).with(formatted_invalid_data).and_return(id)
				post '/traces', invalid_data.to_json, {'CONTENT_TYPE' => Constants::JsonContentType}
				expected_header = "/#{id}"
				expect(last_response.status).to eq HTTPStatus::Created
				expect(last_response.headers["Location"]).to eq expected_header
			end
		end

		context "Invalid Request:" do

			it "url postfixed / should return Not Found" do
				post '/traces/', data.to_json, {'CONTENT_TYPE' => Constants::JsonContentType}
				expect(last_response.status).to eq HTTPStatus::NotFound
			end

			it "invalid content type should return Unsupported Media Type" do
				post '/traces', data.to_json, {'CONTENT_TYPE' => Constants::XmlContentType}
				expect(last_response.status).to eq HTTPStatus::UnsupportedMediaType
			end

			it "empty content type should return Unsupported Media Type" do
				post '/traces', data.to_json
				expect(last_response.status).to eq HTTPStatus::UnsupportedMediaType
			end

			it "null data returns Bad Request" do
				post '/traces', nil, {'CONTENT_TYPE' => Constants::JsonContentType}
				expect(last_response.status).to eq HTTPStatus::BadRequest
			end

			it "empty string data array should return Bad Request" do
				post '/traces', empty_string_data_array.to_json, {'CONTENT_TYPE' => Constants::JsonContentType}
				expect(last_response.status).to eq HTTPStatus::BadRequest
			end

			it "empty string data array 2 should return Bad Request" do
				post '/traces', empty_string_data_array2.to_json, {'CONTENT_TYPE' => Constants::JsonContentType}
				expect(last_response.status).to eq HTTPStatus::BadRequest
			end

			it "empty data array should return Bad Request" do
				post '/traces', empty_data_array.to_json, {'CONTENT_TYPE' => Constants::JsonContentType}
				expect(last_response.status).to eq HTTPStatus::BadRequest
			end	

			it "empty data object should return Bad Request" do
				post '/traces', empty_data_object.to_json, {'CONTENT_TYPE' => Constants::JsonContentType}
				expect(last_response.status).to eq HTTPStatus::BadRequest
			end	

			it "no json coverted data returns No Method Error" do
				expect { 
					post '/traces', Data, {'CONTENT_TYPE' => Constants::JsonContentType}
				}.to raise_error(NoMethodError)
			end

			it "not json data returns Bad Request" do
				post '/traces', invalid_id, {'CONTENT_TYPE' => Constants::JsonContentType}
				expect(last_response.status).to eq HTTPStatus::BadRequest
			end

			it "wrong url returns Not Found" do
				post '/tracessss', data.to_json, {'CONTENT_TYPE' => Constants::JsonContentType}
				expect(last_response.status).to eq HTTPStatus::NotFound
			end
		end

		context "Database Exception:" do

			it "database raises error should return Internal Server Error" do
				expect(repository).to receive(:insert).with(formatted_data).and_return(Constants::DatabaseError)
				post '/traces', data.to_json, {'CONTENT_TYPE' => Constants::JsonContentType}
				expect(last_response.status).to eq HTTPStatus::InternalServerError
			end

			it "repository returns null result should return Internal Server Error" do
				expect(repository).to receive(:insert).with(formatted_data).and_return(nil)
				post '/traces', data.to_json, {'CONTENT_TYPE' => Constants::JsonContentType}
				expect(last_response.status).to eq HTTPStatus::InternalServerError
			end
		end
	 end

	describe "PUT traces:" do
		# before do
		#   expect(cache).to receive(:remove).with(id.to_s).and_return(nil)
 		# end

 		context "Valid Request:" do	

			it "valid data should return No Content" do
				expect(repository).to receive(:update).with(id.to_s, formatted_data).and_return(id)	
				expect(cache).to receive(:remove).with(id.to_s).and_return(nil)
				put "/traces/#{id}", data.to_json, {'CONTENT_TYPE' => Constants::JsonContentType}			
				expect(last_response.status).to eq HTTPStatus::NoContent
			end

			it "data with some invalid items should return No Content" do
				expect(repository).to receive(:update).with(id.to_s, formatted_invalid_data).and_return(id)	
				expect(cache).to receive(:remove).with(id.to_s).and_return(nil)
				put "/traces/#{id}", invalid_data.to_json, {'CONTENT_TYPE' => Constants::JsonContentType}			
				expect(last_response.status).to eq HTTPStatus::NoContent
			end

		end

		context "Invalid Request:" do

			it "url postfixed / should return Not Found" do
				put "/traces/#{id}/", data.to_json, {'CONTENT_TYPE' => Constants::JsonContentType}
				expect(last_response.status).to eq HTTPStatus::NotFound
			end

			it "invalid content type should return Unsupported Media Type" do
				put "/traces/#{id}", data.to_json, {'CONTENT_TYPE' => Constants::XmlContentType}
				expect(last_response.status).to eq HTTPStatus::UnsupportedMediaType
			end

			it "empty content type should return Unsupported Media Type" do
				put "/traces/#{id}", data.to_json
				expect(last_response.status).to eq HTTPStatus::UnsupportedMediaType
			end

			it "not exists id should return Not Found" do
				expect(repository).to receive(:update).with(not_exists_id.to_s, formatted_data).and_return(0)
				put "/traces/#{not_exists_id}", data.to_json, {'CONTENT_TYPE' => Constants::JsonContentType}						
				expect(last_response.status).to eq HTTPStatus::NotFound
			end

			it "invalid id should return Bad Request" do
				put "/traces/#{invalid_id}", data.to_json, {'CONTENT_TYPE' => Constants::JsonContentType}	
				expect(last_response.status).to eq HTTPStatus::BadRequest
			end

			it "no id should return Not Found" do
				put "/traces/", data.to_json, {'CONTENT_TYPE' => Constants::JsonContentType}				
				expect(last_response.status).to eq HTTPStatus::NotFound
			end

			it "no /id should return Not Found" do
				put "/traces", data.to_json, {'CONTENT_TYPE' => Constants::JsonContentType}			
				expect(last_response.status).to eq HTTPStatus::NotFound
			end

			it "null data returns Bad Request" do
				put "/traces/#{id}", nil, {'CONTENT_TYPE' => Constants::JsonContentType}
				expect(last_response.status).to eq HTTPStatus::BadRequest
			end

			it "empty string data array should return Bad Request" do
				put "/traces/#{id}", empty_string_data_array.to_json, {'CONTENT_TYPE' => Constants::JsonContentType}
				expect(last_response.status).to eq HTTPStatus::BadRequest
			end	

			it "empty string data 2 array should return Bad Request" do
				put "/traces/#{id}", empty_string_data_array2.to_json, {'CONTENT_TYPE' => Constants::JsonContentType}
				expect(last_response.status).to eq HTTPStatus::BadRequest
			end	

			it "empty data array should return Bad Request" do
				put "/traces/#{id}", empty_data_array.to_json, {'CONTENT_TYPE' => Constants::JsonContentType}
				expect(last_response.status).to eq HTTPStatus::BadRequest
			end	

			it "empty data object should return Bad Request" do
				put "/traces/#{id}", empty_data_object.to_json, {'CONTENT_TYPE' => Constants::JsonContentType}
				expect(last_response.status).to eq HTTPStatus::BadRequest
			end	

			it "no json coverted data returns No Method Error" do
				expect { 
					put "/traces/#{id}", data, {'CONTENT_TYPE' => Constants::JsonContentType}
				}.to raise_error(NoMethodError)
			end

			it "not json data returns Bad Request" do
				put "/traces/#{id}", invalid_id, {'CONTENT_TYPE' => Constants::JsonContentType}
				expect(last_response.status).to eq HTTPStatus::BadRequest
			end

			it "wrong url returns Not Found" do
				put "/tracesss/#{id}", data.to_json, {'CONTENT_TYPE' => Constants::JsonContentType}			
				expect(last_response.status).to eq HTTPStatus::NotFound	
			end

		end

		context "Database Exception:" do

			it "database raises error should return Internal Server Error" do	
				expect(repository).to receive(:update).with(id.to_s, formatted_data).and_return(Constants::DatabaseError)
				put "/traces/#{id}",data.to_json, {'CONTENT_TYPE' => Constants::JsonContentType}
				expect(last_response.status).to eq HTTPStatus::InternalServerError
			end

			it "repository returns null result should return Internal Server Error" do			
				expect(repository).to receive(:update).with(id.to_s, formatted_data).and_return(nil)
				put "/traces/#{id}", data.to_json, {'CONTENT_TYPE' => Constants::JsonContentType}
				expect(last_response.status).to eq HTTPStatus::InternalServerError
			end

		end
	 end

	describe "Delete traces:" do 

		context "Valid Request:" do

			it "valid id should return OK" do
				expect(repository).to receive(:delete).with(id.to_s).and_return(1)
				expect(cache).to receive(:remove).with(id.to_s).and_return(nil)
				delete "/traces/#{id}"		
				expect(last_response.status).to eq HTTPStatus::OK
			end
			
		end

		context "Invalid Request:" do

			it "url postfixed / should return Not Found" do
				delete "/traces/#{id}/"		
				expect(last_response.status).to eq HTTPStatus::NotFound
			end

			it "not exists id should return Not Found" do	
				expect(repository).to receive(:delete).with(not_exists_id.to_s).and_return(0)		
				delete "/traces/#{not_exists_id}"				
				expect(last_response.status).to eq HTTPStatus::NotFound
			end

			it "invalid id should return Bad Request" do
				delete "/traces/#{invalid_id}"			
				expect(last_response.status).to eq HTTPStatus::BadRequest
			end

			it "no id should return Not Found" do
				delete "/traces/"			
				expect(last_response.status).to eq HTTPStatus::NotFound
			end

			it "no /id should return Not Found" do
				delete "/traces"			
				expect(last_response.status).to eq HTTPStatus::NotFound
			end

			it "wrong url returns Not Found" do
				delete "/tracesss/#{id}"	
				expect(last_response.status).to eq HTTPStatus::NotFound	
			end

		end

		context "Database Exception:" do

			it "database raises error should return Internal Server Error" do
				expect(repository).to receive(:delete).with(id.to_s).and_return(Constants::DatabaseError)
				delete "/traces/#{id}"				
				expect(last_response.status).to eq HTTPStatus::InternalServerError
			end

			it "repository returns null result should return Internal Server Error" do			
				expect(repository).to receive(:delete).with(id.to_s).and_return(nil)
				delete "/traces/#{id}", data.to_json, {'CONTENT_TYPE' => Constants::JsonContentType}
				expect(last_response.status).to eq HTTPStatus::InternalServerError
			end

		end
	 end

end