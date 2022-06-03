require 'test_helper'

describe BureauConsultant::EstablishmentsController do
  let(:parsed) { JSON.parse response.body }

  describe 'authenticated as a consultant' do
    before do
      sign_in cas_authentications(:jackie_denesik)
    end

    describe 'when searching the goxygene database' do

      describe 'with an existing siret' do
        let(:siret) { '51817284600017' }

        before {
          get "/bureau_consultant/establishments/#{siret}"
        }

        it 'renders the page' do
          assert_response :success
        end

        it 'returns the siret' do
          assert_equal siret, parsed['siret']
        end

        it 'returns the establishment name' do
          assert_equal 'FTOPIA SAS', parsed['name']
        end

        describe 'with extra spaces within' do
          let(:siret) { '518%20172%20846%2000017' }

          before {
            get "/bureau_consultant/establishments/#{siret}"
          }

          it 'renders the page' do
            assert_response :success
          end

          it 'returns the siret' do
            assert_equal '51817284600017', parsed['siret']
          end

          it 'returns the establishment name' do
            assert_equal 'FTOPIA SAS', parsed['name']
          end
        end

        describe 'with spaces and tabs' do
          let(:siret) { '%09518%20172%20846%2000017' }

          before {
            get "/bureau_consultant/establishments/#{siret}"
          }

          it 'renders the page' do
            assert_response :success
          end

          it 'returns the siret' do
            assert_equal '51817284600017', parsed['siret']
          end

          it 'returns the establishment name' do
            assert_equal 'FTOPIA SAS', parsed['name']
          end
        end
      end

      describe 'with an unknown siret' do
        let(:siret) { '1234567890123' }

        it 'returns a not found code' do
          get "/bureau_consultant/establishments/#{siret}"
          assert_response :not_found
        end
      end

      describe 'with an incomplete siret' do
        let(:siret) { '1234567890' }

        it 'returns a not found code' do
          get "/bureau_consultant/establishments/#{siret}"
          assert_response :not_found
        end
      end

    end
  end

  describe 'not authenticated' do
    it 'redirects to the authentication page' do
      get '/bureau_consultant/establishments/51817284600017'
      assert_redirected_to '/cas_authentications/sign_in'
    end
  end
end
