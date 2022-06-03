require 'test_helper'

describe BureauConsultant::SalariesController do

  let(:consultant) { Goxygene::Consultant.find 9392 }
  let(:wage)       { consultant.wages.last }

  describe 'authenticated as a consultant' do
    before { sign_in cas_authentications(:jackie_denesik) }

    describe 'download' do
      it 'redirects to a S3 link' do
        get "/bureau_consultant/salaries/#{wage.id}/download.pdf"

        assert_redirected_to wage.document.filename.url
      end
    end
  end

end
