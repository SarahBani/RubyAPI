# spec/cache_spec.rb
require './spec_helper'

RSpec.describe Cache do

	before (:all) do
		puts '------------Start Testing Cache-------------'
		Cache.clear
	end

	after (:all) do
		puts '------------End Testing Cache---------------'	
		Cache.clear
		Cache.close
	end

	let(:key) { 8 }
	let(:not_exists_key) { -1 }

  	let(:data) {[
			{ "latitude": 32.9377784729004, "longitude": -117.230392456055},
			{ "latitude": 32.937801361084, "longitude": -117.230323791504},
			{ "latitude": 32.9378204345703, "longitude": -117.230278015137}
		]}
  	let(:data_elevations) {[
			4139,
			4139,
			4139
	  	]}
  	let(:data_with_attributes) {[
			{ "latitude": 32.9377784729004, "longitude": -117.230392456055, "distance": 0, "elevation": 4139},
			{ "latitude": 32.937801361084, "longitude": -117.230323791504, "distance": 6, "elevation": 4139},
			{ "latitude": 32.9378204345703, "longitude": -117.230278015137, "distance": 11, "elevation": 4139}
		]}
	let(:formatted_data) { JSON.parse(data.to_json) }
	let(:formatted_data_with_attributes) { JSON.parse(data_with_attributes.to_json) }	

  	let(:invalid_data) {[
			{ "latitude": 32.9377784729004, "longitude": -117.230392456055 },
			{ "latitude": 32.937801361084},
			{ "latitude": 32.937801361084, "longitude": -117.230323791504 },
			{ "name": 32.937801361084},		
			{ "latitude": 32.9378204345703, "longitude": -117.230278015137 },	
			{ "latitude": 32978.20445703, "longitude": -1174.2}, # invalid lat & long
			{ "latitude": 32.9378204345703, "longitude": -117.230239868164 }
		]}
	let(:invalid_data_elevations) {[
		    4139,
		    0,
		    4139,
		    0,
		    4139,
		    4992,
		    4139
	  	]}
	let(:formatted_invalid_data) { JSON.parse(invalid_data.to_json) }
  	let(:invalid_data_with_some_attributes) {[
			{ "latitude": 32.9377784729004, "longitude": -117.230392456055, "distance": 0, "elevation": 4139},
			{ "latitude": 32.937801361084, "elevation": 0},
			{ "latitude": 32.937801361084, "longitude": -117.230323791504, "distance": 6, "elevation": 4139},
			{ "name": 32.937801361084, "elevation": 0},		
			{ "latitude": 32.9378204345703, "longitude": -117.230278015137, "distance": 11, "elevation": 4139},
			{ "latitude": 32978.20445703, "longitude": -1174.2, "distance": 17857772, "elevation": 4992},
			{ "latitude": 32.9378204345703, "longitude": -117.230239868164, "distance": 35715535, "elevation": 4139 }
		]}	
	let(:formatted_invalid_data_with_some_attributes) { JSON.parse(invalid_data_with_some_attributes.to_json) }
	
	let(:other_type_data) { 'sss' }
	let(:formatted_other_type_data) { JSON.parse(other_type_data.to_json) }

    let(:repository) { Repository }
    let(:elevationServiceClient) { ElevationServiceClient }

	describe "fetch:" do

		context "Data Exists in Database:" do

			before (:each) do
				Cache.clear
			end

			it "key not exist should fetch data from database & return data with attributes" do
				expect(repository).to receive(:select_item).with(key.to_s).and_return(formatted_data)
				expect(elevationServiceClient).to receive(:get_elevations_bulk).with(formatted_data).and_return(data_elevations)				
				result = Cache.fetch key.to_s do
				 	Repository.select_item key.to_s
				end 
				expect(result).to eq(formatted_data_with_attributes)
			end

			it "key not exist should fetch invalid data from database & return data with attributes in some items" do
				expect(repository).to receive(:select_item).with(key.to_s).and_return(formatted_invalid_data)
				expect(elevationServiceClient).to receive(:get_elevations_bulk).with(formatted_invalid_data).and_return(invalid_data_elevations)				
				result = Cache.fetch key.to_s do
				 	Repository.select_item key.to_s
				end 
				expect(result).to eq(formatted_invalid_data_with_some_attributes)
			end

			it "key not exist should fetch other type data from database & return data without attributes" do
				expect(repository).to receive(:select_item).with(key.to_s).and_return(formatted_other_type_data)
				result = Cache.fetch key.to_s do
				 	Repository.select_item key.to_s
				end 
				expect(result).to eq(formatted_other_type_data)
			end

		end

		context "Data Not Exists in Database:" do

			it "key exists neither in cache and in database, should return nil" do
				expect(repository).to receive(:select_item).with(not_exists_key.to_s).and_return(nil)
				result = Cache.fetch not_exists_key.to_s do
				 	Repository.select_item not_exists_key.to_s
				end 
				expect(result).to eq(nil)
			end

		end
		
	end

	describe "exists:" do

		it "key not exist should return false" do							
			result = Cache.exists not_exists_key.to_s
			expect(result).to eq(false)
		end

	end

	describe "remove:" do
		
		context "Key Not Exists:" do

			it "key not exist should return nil" do							
				result = Cache.remove not_exists_key.to_s
				expect(result).to eq(nil)
			end

		end

	end

	describe "multiple operations in order:" do

		before :all do
			Cache.clear
		end

		context "Whole Operations of adding to cache & fetch & remove:" do

			it "the key not exists & should be fetched from database & add attributes & add to cache" do		
				expect(repository).to receive(:select_item).with(key.to_s).and_return(formatted_data)
				expect(elevationServiceClient).to receive(:get_elevations_bulk).with(formatted_data).and_return(data_elevations)												
				result = Cache.fetch key.to_s do
				 	Repository.select_item key.to_s
				end 
				expect(result).to eq(formatted_data_with_attributes)	
			end
							
			it "now check if the key has been added" do
				result = Cache.exists key.to_s 
				expect(result).to eq(true)							
			end
							
			it "now the key exists & should be fetched from cache" do
				result = Cache.fetch key.to_s do
				 	nil
				end 
				expect(result).to eq(formatted_data_with_attributes)
			end
							
			it "now remove the key from cache" do
				result = Cache.remove key.to_s 
				expect(result).to eq(1)
			end
							
			it "now check if the key has been removed" do
				result = Cache.exists key.to_s 
				expect(result).to eq(false)							
			end
		
		end

		context "Whole Operations of adding to cache & clear cache:" do

			it "the key not exists & should be fetched from database & add attributes & add to cache" do		
				expect(repository).to receive(:select_item).with(key.to_s).and_return(formatted_data_with_attributes)
				result = Cache.fetch key.to_s do
				 	Repository.select_item key.to_s
				end 
				expect(result).to eq(formatted_data_with_attributes)	
			end
							
			it "now check if the key has been added" do
				result = Cache.exists key.to_s 
				expect(result).to eq(true)							
			end
							
			it "now clear cache" do
				result = Cache.clear
				expect(result).to eq('OK')
			end
							
			it "now check if the key has been removed" do
				result = Cache.exists key.to_s 
				expect(result).to eq(false)							
			end
			
		end

	end

end