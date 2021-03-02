# spec/helper_module_spec.rb

RSpec.describe HelperModule do

	before (:all) do
		puts '---------Start Testing HelperModule----------'
		Cache.clear
	end

	after (:all) do
		puts '---------End Testing HelperModule------------'	
		Cache.clear
		Cache.close
	end

	let(:data) {{ "latitude": 48.234, "longitude": 12.422134}}
	let(:formatted_data) { JSON.parse(data.to_json) }

	let(:data2) {{ "latitude": 48234, "longitude": -12422.134}}
	let(:formatted_data2) { JSON.parse(data2.to_json) }

	let(:data3) {{ "latitude": 0, "longitude": 0}}
	let(:formatted_data3) { JSON.parse(data3.to_json) }

	let(:invalid_data) {{ "latitude": 48.234 }}
  	let(:formatted_invalid_data) { JSON.parse(invalid_data.to_json) }

	let(:invalid_data2) {{ "name": 48.234 }}
  	let(:formatted_invalid_data2) { JSON.parse(invalid_data2.to_json) }

  	let(:empty_string_data_array) {[""]}
	let(:empty_string_data_array2) {['']}
	let(:empty_data_array) {[]}
	let(:empty_data_object) {{}}

	describe "is_test_environment:" do

		it "it's test environment, should return true" do
			result = HelperModule.is_test_environment?
			expect(result).to eq(true)
		end

	end

	describe "is_float:" do

		context "Float Value:" do

			it "float value 1, should return true" do
				result = HelperModule.is_float? 2131.554
				expect(result).to eq(true)
			end
			
			it "float value 2, should return true" do
				result = HelperModule.is_float? 0.554
				expect(result).to eq(true)
			end
			
			it "0 value, should return true" do
				result = HelperModule.is_float? 0
				expect(result).to eq(true)
			end
			
			it "integer value, should return true" do
				result = HelperModule.is_float? 354564
				expect(result).to eq(true)
			end
			
			it "string float value, should return true" do
				result = HelperModule.is_float? '2131.554'
				expect(result).to eq(true)
			end

		end

		context "Not Float Value:" do

			it "nil value, should return false" do
				result = HelperModule.is_float? nil
				expect(result).to eq(false)
			end

			it "string value, should return false" do
				result = HelperModule.is_float? 'sss'
				expect(result).to eq(false)
			end

		end

	end

	describe "is_trace_valid:" do

		context "Valid Value:" do

			it "valid value, should return true" do
				result = HelperModule.is_trace_valid? formatted_data
				expect(result).to eq(true)
			end

			it "valid value 2, should return true" do
				result = HelperModule.is_trace_valid? formatted_data2
				expect(result).to eq(true)
			end

			it "valid value 3, should return true" do
				result = HelperModule.is_trace_valid? formatted_data3
				expect(result).to eq(true)
			end

		end

		context "Invalid Value:" do

			it "invalid value, should return false" do
				result = HelperModule.is_trace_valid? formatted_invalid_data
				expect(result).to eq(false)
			end

			it "invalid value 2, should return false" do
				result = HelperModule.is_trace_valid? formatted_invalid_data2
				expect(result).to eq(false)
			end

			it "empty string data array, should return false" do
				result = HelperModule.is_trace_valid? empty_string_data_array
				expect(result).to eq(false)
			end

			it "empty string data array 2, should return false" do
				result = HelperModule.is_trace_valid? empty_string_data_array2
				expect(result).to eq(false)
			end

			it "empty data array, should return false" do
				result = HelperModule.is_trace_valid? empty_data_array
				expect(result).to eq(false)
			end

			it "empty data object, should return false" do
				result = HelperModule.is_trace_valid? empty_data_object
				expect(result).to eq(false)
			end

		end

	end	

	describe "has_value:" do

		context "Data With Value:" do

			it "valid data, should return true" do
				result = HelperModule.has_value? formatted_data
				expect(result).to eq(true)
			end

			it "valid data 2, should return true" do
				result = HelperModule.has_value? formatted_data2
				expect(result).to eq(true)
			end

			it "valid data 3, should return true" do
				result = HelperModule.has_value? formatted_data3
				expect(result).to eq(true)
			end

			it "invalid data, should return false" do
				result = HelperModule.has_value? formatted_invalid_data
				expect(result).to eq(true)
			end

			it "invalid data 2, but valid data, should return false" do
				result = HelperModule.has_value? formatted_invalid_data2
				expect(result).to eq(true)
			end

		end

		context "Empty Data:" do			

			it "empty string data array, should return false" do
				result = HelperModule.has_value? empty_string_data_array
				expect(result).to eq(false)
			end

			it "empty string data array 2, should return false" do
				result = HelperModule.has_value? empty_string_data_array2
				expect(result).to eq(false)
			end

			it "empty string data array 2, should return false" do
				result = HelperModule.has_value? empty_string_data_array2
				expect(result).to eq(false)
			end

			it "empty data array, should return false" do
				result = HelperModule.has_value? empty_data_array
				expect(result).to eq(false)
			end

			it "empty data object, should return false" do
				result = HelperModule.has_value? empty_data_object
				expect(result).to eq(false)
			end


		end

	end

end