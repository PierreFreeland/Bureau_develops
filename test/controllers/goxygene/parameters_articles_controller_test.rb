require 'test_helper'

describe Goxygene::ParametersBureauConsultantArticlesController do

  describe 'authenticated as an administrator' do

    let(:article)    { Goxygene::Article.all.shuffle.first }
    let(:over_title) { FFaker::Lorem.words(5).join(' ')    }
    let(:title)      { FFaker::Lorem.words(5).join(' ')    }
    let(:chapo)      { FFaker::Lorem.words(250).join(' ')  }
    let(:text)       { FFaker::Lorem.words(250).join(' ')  }
    let(:on_special) { [true, false].shuffle.first         }
    let(:state)      { [true, false].shuffle.first         }
    let(:topics)     { [ Goxygene::ArticleTopic.all.shuffle.first ] }

    before do
      sign_in cas_authentications(:administrator)
    end

    describe 'when listing articles' do
      before { get '/goxygene/parameters/bureau_consultant/articles' }

      it 'renders the page' do
        assert_response :success
      end

      it 'displays multiple items' do
        assert_select 'tbody tr.article', 3
      end

      it 'displays a deletion link' do
        assert_select 'tr.article td.actions a.destroy', 3
      end
    end

    describe 'when editing an article' do
      before { get "/goxygene/parameters/bureau_consultant/articles/#{article.id}" }

      it 'renders the page' do
        assert_response :success
      end

      it 'includes a form to edit the article' do
        assert_select 'form'
      end

      it 'includes a field for the over title' do
        assert_select 'form input[type="text"][name="article[over_title]"]'
      end

      it 'includes a field for the title' do
        assert_select 'form input[type="text"][name="article[title]"]'
      end

      it 'includes a field for the chapo' do
        assert_select 'form textarea[name="article[chapo]"]'
      end

      it 'includes a field for the text' do
        assert_select 'form textarea[name="article[text]"]'
      end

      it 'includes a submit button' do
        assert_select 'form button[type="submit"]'
      end
    end

    describe 'when updating an article' do
      before do
        patch "/goxygene/parameters/bureau_consultant/articles/#{article.id}", params: {
          article: {
            over_title: over_title,
            title:      title,
            chapo:      chapo,
            text:       text,
            on_special: on_special,
            state:      state,
            topic_ids:  topics.collect(&:id)
          }
        }
      end

      it 'redirects to the articles list' do
        assert_redirected_to '/goxygene/parameters/bureau_consultant/articles'
      end

      it 'saves the over title field' do
        assert_equal over_title, article.reload.over_title
      end

      it 'saves the title field' do
        assert_equal title, article.reload.title
      end

      it 'saves the text field' do
        assert_equal text, article.reload.text
      end

      it 'saves the chapo field' do
        assert_equal chapo, article.reload.chapo
      end

      it 'saves the state field' do
        assert_equal state, article.reload.state
      end

      it 'saves the on_special field' do
        assert_equal on_special, article.reload.on_special
      end

      it 'saves the topics' do
        assert_equal topics, article.reload.topics.to_a
      end

      it 'saves the bureau' do
        assert_equal 'consultant', article.bureau
      end
    end

    describe 'when destroying an article' do
      it 'removes the article from database' do
        assert_difference 'Goxygene::Article.count', -1 do
          delete "/goxygene/parameters/bureau_consultant/articles/#{article.id}"
        end
      end

      it 'redirects to the articles page' do
        delete "/goxygene/parameters/bureau_consultant/articles/#{article.id}"

        assert_redirected_to '/goxygene/parameters/bureau_consultant/articles'
      end
    end

    describe 'when displaying the new page' do
      it 'renders the page' do
        get "/goxygene/parameters/bureau_consultant/articles/new"

        assert_response :success
      end
    end

    describe 'when creating an article' do
      let(:article) { Goxygene::Article.last }

      def post_create_article
        post "/goxygene/parameters/bureau_consultant/articles", params: {
          article: {
            over_title: over_title,
            title:      title,
            chapo:      chapo,
            text:       text,
            on_special: on_special,
            state:      state,
            topic_ids:  topics.collect(&:id)
          }
        }
      end

      it 'creates a new entry in database' do
        assert_difference 'Goxygene::Article.count' do
          post_create_article
        end
      end

      it 'redirects to the articles list' do
        post_create_article
        assert_redirected_to '/goxygene/parameters/bureau_consultant/articles'
      end

      it 'saves the over title field' do
        post_create_article
        assert_equal over_title, article.reload.over_title
      end

      it 'saves the title field' do
        post_create_article
        assert_equal title, article.reload.title
      end

      it 'saves the text field' do
        post_create_article
        assert_equal text, article.reload.text
      end

      it 'saves the chapo field' do
        post_create_article
        assert_equal chapo, article.reload.chapo
      end

      it 'saves the state field' do
        post_create_article
        assert_equal state, article.reload.state
      end

      it 'saves the on_special field' do
        post_create_article
        assert_equal on_special, article.reload.on_special
      end

      it 'saves the topics' do
        post_create_article
        assert_equal topics, article.reload.topics.to_a
      end

      it 'saves the bureau' do
        post_create_article
        assert_equal 'consultant', article.reload.bureau
      end
    end

  end

  describe 'not authenticated' do
    describe 'when listing articles' do
      it 'redirects to the authentication page' do
        get '/goxygene/parameters/bureau_consultant/articles'
        assert_redirected_to '/cas_authentications/sign_in'
      end
    end
  end
end
