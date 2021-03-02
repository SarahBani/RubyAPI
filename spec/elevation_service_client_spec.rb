# spec/elevation_service_client_spec.rb
require './spec_helper'

RSpec.describe ElevationServiceClient do

	before (:all) do
		puts '-------Start Testing ElevationServiceClient------'
	end

	after (:all) do
		puts '-------End Testing ElevationServiceClient--------'	
	end

  	let(:single_data) {{ "latitude": 48.234, "longitude": 12.422134}}
	let(:formatted_single_data) { JSON.parse(single_data.to_json) }
  	let(:single_data_reponse) { 599 }

  	let(:invalid_single_data) {{ "latitude": 48.234 }}
  	let(:formatted_invalid_single_data) { JSON.parse(invalid_single_data.to_json) }
  	let(:invalid_single_data2) {{ "name": 48.234 }}
  	let(:formatted_invalid_single_data2) { JSON.parse(invalid_single_data2.to_json) }
  	let(:invalid_single_data3) {{ "latitude": 4824.345, "longitude": -12424.345}}
  	let(:formatted_invalid_single_data3) { JSON.parse(invalid_single_data3.to_json) }
  	let(:invalid_single_data3_reponse) { 4673 }

  	let(:bulk_data) {[
			{ "latitude": 32.9377784729004, "longitude": -117.230392456055},
			{ "latitude": 32.937801361084, "longitude": -117.230323791504},
			{ "latitude": 32.9378204345703, "longitude": -117.230278015137}
		]}
  	let(:formatted_bulk_data)  { JSON.parse(bulk_data.to_json) }
  	let(:bulk_data_reponse) {[
		    4139,
		    4139,
		    4139
		]}		

  	let(:invalid_bulk_data) {[
			{ "latitude": 32.9377784729004, "longitude": -117.230392456055},
			{ "latitude": 32.937801361084},
			{ "latitude": 32978.20445703, "longitude": -1174.2},
			{ "name": 32.937801361084},
			{ "latitude": 32.9378204345703, "longitude": -117.230278015137}
		]}	
  	let(:formatted_invalid_bulk_data)  { JSON.parse(invalid_bulk_data.to_json) }
  	let(:invalid_bulk_data_reponse) {[
		    4139,
		    0,
		    4992,
		    0,
		    4139
		]}	

  	let(:invalid_data) { 'sss' }
  	let(:formatted_invalid_data)  { JSON.parse(invalid_data.to_json) }

	let(:empty_string_data_array) {[""]}
	let(:empty_string_data_array2) {['']}
	let(:empty_data_array) {[]}
	let(:empty_data_object) {{}}

	describe "get_elevations_single:" do

		context "Valid Request:" do

			it "valid single data request, should return response" do
				result = ElevationServiceClient.get_elevations_single formatted_single_data
				expect(result).to eq(single_data_reponse.to_s)
			end

		end

		context "Invalid Request:" do

			it "invalid single data request, should return nil" do
				result = ElevationServiceClient.get_elevations_single formatted_invalid_single_data
				expect(result).to eq(nil)
			end

			it "invalid single data 2 request, should return nil" do
				result = ElevationServiceClient.get_elevations_single formatted_invalid_single_data2
				expect(result).to eq(nil)
			end

			it "invalid single data 3 request, should return nil" do
				result = ElevationServiceClient.get_elevations_single formatted_invalid_single_data3
				expect(result).to eq(invalid_single_data3_reponse.to_s)
			end

			it "invalid data request, should return nil" do
				result = ElevationServiceClient.get_elevations_single formatted_invalid_data
				expect(result).to eq(nil)
			end

			it "empty string data array request, should return nil" do
				result = ElevationServiceClient.get_elevations_single empty_string_data_array
				expect(result).to eq(nil)
			end

			it "empty string data array 2 request, should return nil" do
				result = ElevationServiceClient.get_elevations_single empty_string_data_array2
				expect(result).to eq(nil)
			end

			it "empty data object request, should return nil" do
				result = ElevationServiceClient.get_elevations_single empty_data_object
				expect(result).to eq(nil)
			end

			it "empty data array request, should return nil" do
				result = ElevationServiceClient.get_elevations_single empty_data_array
				expect(result).to eq(nil)
			end

			it "bulk data request, should return nil" do
				result = ElevationServiceClient.get_elevations_single formatted_bulk_data
				expect(result).to eq(nil)
			end

			it "nil request, should return nil" do
				result = ElevationServiceClient.get_elevations_single nil
				expect(result).to eq(nil)
			end

		end

	end

	describe "get_elevations_bulk:" do

		context "Valid Request:" do

			it "valid bulk data request, should return response" do
				result = ElevationServiceClient.get_elevations_bulk formatted_bulk_data
				expect(result).to eq(bulk_data_reponse)
			end

		end

		context "Invalid Request:" do

			it "invalid bulk data request, should return response for some data" do
				result = ElevationServiceClient.get_elevations_bulk formatted_invalid_bulk_data
				expect(result).to eq(invalid_bulk_data_reponse)
			end

			it "invalid data request, should return nil" do
				result = ElevationServiceClient.get_elevations_bulk formatted_invalid_data
				expect(result).to eq(nil)
			end

			it "empty string data array request, should return 0" do
				result = ElevationServiceClient.get_elevations_bulk empty_string_data_array
				expect(result).to eq([0])
			end

			it "empty string data array 2 request, should return 0" do
				result = ElevationServiceClient.get_elevations_bulk empty_string_data_array2
				expect(result).to eq([0])
			end

			it "empty data array request, should return empty array" do
				result = ElevationServiceClient.get_elevations_bulk empty_data_array
				expect(result).to eq([])
			end

			it "empty data object request, should return empty array" do
				result = ElevationServiceClient.get_elevations_bulk empty_data_object
				expect(result).to eq([])
			end

			it "single data request, should return nil" do
				result = ElevationServiceClient.get_elevations_bulk formatted_single_data
				expect(result).to eq(nil)
			end

			it "nil request, should return nil" do
				result = ElevationServiceClient.get_elevations_bulk nil
				expect(result).to eq(nil)
			end

		end

	end

end