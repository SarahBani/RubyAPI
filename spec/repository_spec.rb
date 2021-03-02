# spec/repository_spec.rb
require './spec_helper'

RSpec.describe Repository do	

	before (:all) do
		puts '------------Start Testing Repository-----------'
		Repository.finalize
	end

	after (:all) do
		puts '------------End Testing Repository-------------'
		# Repository.finalize	
	end

	id = 0
	let(:not_exists_id) { -1 }
	let(:invalid_id) { 'sss' }
  	let(:data) {[
			{ "latitude": 32.9377784729004, "longitude": -117.230392456055 },
		    { "latitude": 32.937801361084, "longitude": -117.230323791504 },
		    { "latitude": 32.9379615783691, "longitude": -117.229919433594 }
		]}
  	let(:formatted_data) { JSON.parse(data.to_json) }
	let(:other_type_data) { 'sss' }
  	let(:formatted_other_type_data) { JSON.parse(other_type_data.to_json) }
	let(:empty_string_data_array) {[""]}
	let(:empty_string_data_array2) {['']}
	let(:empty_data_array) {[]}
	let(:empty_data_object) {{}}

	describe "select_item:" do

		context "Data Not Exists:" do

			it "id not exists should return nill" do
				result = Repository.select_item not_exists_id
				expect(result).to eq(nil)
			end

			it "invalid id, should return nil" do
				result = Repository.select_item invalid_id
				expect(result).to eq(nil)
			end

		end
		
	end

	describe "insert:" do

		before (:each) do
			id += 1
		end

		context "Valid Data:" do

			it "should insert into database & return id" do
				result = Repository.insert formatted_data
				expect(result).to eq(id)	
			end

		end

		context "Other Data:" do

			it "other type data should insert into database return id" do	
				result = Repository.insert other_type_data
				expect(result).to eq(id)
			end

			it "formatted other type data should insert into database return id" do	
				result = Repository.insert formatted_other_type_data
				expect(result).to eq(id)
			end

			it "empty string data array should insert into database return id" do
				result = Repository.insert empty_string_data_array
				expect(result).to eq(id)
			end

			it "empty string data array 2 should insert into database return id" do
				result = Repository.insert empty_string_data_array2
				expect(result).to eq(id)
			end

			it "empty data array should insert into database return id" do
				result = Repository.insert empty_data_array
				expect(result).to eq(id)
			end

			it "empty data object should insert into database return id" do	
				result = Repository.insert empty_data_object
				expect(result).to eq(id)
			end

		end

	end

	describe "update:" do

		context "Id Exists:" do

			it "valid data, should update database & return 1" do
				result = Repository.update id, formatted_data
				expect(result).to eq(1)	
			end

			it "other type data, should update database & return 1" do
				result = Repository.update id, other_type_data
				expect(result).to eq(1)	
			end

			it "formatted other type data, should update database & return 1" do
				result = Repository.update id, formatted_other_type_data
				expect(result).to eq(1)	
			end

			it "empty string data array, should update database & return 1" do
				result = Repository.update id, empty_string_data_array
				expect(result).to eq(1)	
			end

			it "empty string data array 2, should update database & return 1" do
				result = Repository.update id, empty_string_data_array2
				expect(result).to eq(1)	
			end

			it "empty data array, should update database & return 1" do
				result = Repository.update id, empty_data_array
				expect(result).to eq(1)	
			end

			it "empty data object, should update database & return 1" do
				result = Repository.update id, empty_data_object
				expect(result).to eq(1)	
			end

		end

		context "Id Not Exists:" do

			it "cannot update database & should return 0" do
				result = Repository.update not_exists_id, formatted_data
				expect(result).to eq(0)	
			end

			it "invalid id, cannot update & return 0" do
				result = Repository.update invalid_id, formatted_data
				expect(result).to eq(0)	
			end

		end

	end

	describe "delete:" do

		context "Id Exists:" do

			it "should delete from database & return 1" do
				result = Repository.delete id
				expect(result).to eq(1)	
			end

		end

		context "Id Not Exists:" do

			it "should not delete from database & return 0" do
				result = Repository.delete not_exists_id
				expect(result).to eq(0)	
			end

			it "invalid id, should not delete from database & return 0" do
				result = Repository.delete invalid_id
				expect(result).to eq(0)	
			end

		end

	end

	describe "multiple operations in order:" do

  		let(:changed_data) {[
			  				{ "latitude": 32.9377784729004, "longitude": -117.230392456055 },
						    { "latitude": 32.937801361084, "longitude": -117.230323791504 },
							]}
		let(:formatted_changed_data) { JSON.parse(changed_data.to_json) }

		context "Whole Operations of Insert & Update & Remove & Fetch:" do

			it "should insert & return id" do	
				result = Repository.insert formatted_data
				expect(result).to eq(id)	
			end

			it "id exists, fetch from database and should return data" do
				result = Repository.select_item id
				expect(result).to eq(formatted_data)
			end

			it "update database & return 1" do
				result = Repository.update id, formatted_changed_data
				expect(result).to eq(1)	
			end

			it "id exists, fetch from database and should return changed data" do
				result = Repository.select_item id
				expect(result).to eq(formatted_changed_data)
			end

			it "id exists, should delete from database & return 1" do
				result = Repository.delete id
				expect(result).to eq(1)	
			end

			it "id not exists any more, cannot fetch from database and should return nil" do
				result = Repository.select_item id
				expect(result).to eq(nil)
			end

		end

	end	

end