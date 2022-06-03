require 'test_helper'

describe BureauConsultant::ArticlesController do
  let(:article) { Goxygene::Article.all.shuffle.last }

  describe 'authenticated as a consultant' do
    before do
      sign_in cas_authentications(:jackie_denesik)
    end

    describe 'on a mobile' do
      it 'displays the article' do
        get "/m/bureau_consultant/articles/#{article.id}"
        assert_response :success
      end

      it 'displays the topics' do
        get "/m/bureau_consultant/articles"
        assert_response :success
      end
    end

    it 'displays the article' do
      get "/bureau_consultant/articles/#{article.id}"
      assert_response :success
    end

    it 'displays the topics' do
      get "/bureau_consultant/articles"
      assert_response :success
    end
  end

  describe 'not authenticated' do
    it 'redirects to the authentication page when displaying an article' do
      get "/bureau_consultant/articles/#{article.id}"
      assert_redirected_to '/cas_authentications/sign_in'
    end

    it 'redirects to the authentication page when listing topics' do
      get "/bureau_consultant/articles"
      assert_redirected_to '/cas_authentications/sign_in'
    end
  end
end
