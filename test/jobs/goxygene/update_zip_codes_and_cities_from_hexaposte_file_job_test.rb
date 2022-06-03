require 'test_helper'

class UpdateZipCodesAndCitiesFromHexaposteFileJobTest < ActiveJob::TestCase
   describe 'Test of update of zipcodes and cities from hexaposte file' do
   	describe 'Test base file' do
       before do
  		     Goxygene::UpdateZipCodesAndCitiesFromHexaposteFileJob.perform_now("./test/fixtures/files/mediaposte/")
       end

   		describe 'Check that city at been added correctly' do
   			let(:paris_19) 	{ Goxygene::City.from_insee_code '75119' }

   			it 'Must found the city' do
   				assert_equal paris_19.insee_code, '75119'
   			end

   			it 'The city name is with out district' do
   				assert_equal paris_19.city, 'PARIS'
   			end

   			it 'The town containt the district number' do
   				assert_equal paris_19.town, 'PARIS 19'
   			end
   		end

   		describe 'Check that zip code at been added ' do
   			let(:zip08) {Goxygene::ZipCode.find_by insee_code: '573440'}
   			it 'Must  found the zip code' do
   				assert_equal zip08.insee_code, '573440'
   				assert_equal zip08.zip_code, '75800'
   			end

   			it 'return the good routing_label ' do
   				assert_equal zip08.routing_label, 'PARIS CEDEX 08'
   			end
   		end

   		describe 'Check that we can find the good zip_code_id' do
   			describe 'Check case without CEDEX' do
   				let(:paris_01_id) {Goxygene::ZipCode.id_from_zipcode_and_city('75001', 'Paris')}
   				let(:paris_01)  {Goxygene::ZipCode.find paris_01_id}

   				it 'Must find la ville lumière' do
						assert_equal paris_01.insee_code, '32457'
						assert_equal paris_01.routing_label, 'PARIS'
   				end
   			end

   			describe 'check case with CEDEX' do
   				let(:paris_cedex_id) {Goxygene::ZipCode.id_from_zipcode_and_city('75021', 'Paris CEDEX 01')}
   				let(:paris_01_cedex)  {Goxygene::ZipCode.find paris_cedex_id}

   				it 'Must find a cedex in the first district of Paris' do
						assert_equal paris_01_cedex.insee_code, '573204'
						assert_equal paris_01_cedex.routing_label, 'PARIS CEDEX 01'
   				end
   			end
   		end
   	end
   end

end
