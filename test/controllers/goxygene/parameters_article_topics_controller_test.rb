require 'test_helper'

describe Goxygene::ParametersBureauConsultantArticleTopicsController do

  describe 'authenticated as an administrator' do

    let(:topic)       { Goxygene::ArticleTopic.all.shuffle.first }
    let(:topic_name)  { FFaker::Lorem.words(5).join(' ')[0..49]  }
    let(:description) { FFaker::Lorem.words(250).join(' ')       }

    before do
      sign_in cas_authentications(:administrator)
    end

    describe 'when listing topics' do
      before { get '/goxygene/parameters/bureau_consultant/article_topics' }

      it 'renders the page' do
        assert_response :success
      end

      it 'displays pagination links' do
        skip if Goxygene::ArticleTopic.count < 25
        assert_select 'nav.pagination'
      end

      it 'displays multiple items' do
        assert_select 'tbody tr.topic', Goxygene::ArticleTopic.count
      end

      it 'displays a deletion link' do
        assert_select 'tr.topic td.actions a.destroy', Goxygene::ArticleTopic.count
      end
    end

    describe 'when editing a topic' do
      before { get "/goxygene/parameters/bureau_consultant/article_topics/#{topic.id}" }

      it 'renders the page' do
        assert_response :success
      end

      it 'includes a form to edit the topic' do
        assert_select 'form'
      end

      it 'includes a field for the name' do
        assert_select 'form input[type="text"][name="article_topic[name]"]'
      end

      it 'includes a field for the description' do
        assert_select 'form textarea[name="article_topic[description]"]'
      end
    end

    describe 'when updating a topic' do
      before do
        patch "/goxygene/parameters/bureau_consultant/article_topics/#{topic.id}", params: {
          article_topic: {
            name:        topic_name,
            description: description
          }
        }
      end

      it 'redirects to the articles list' do
        assert_redirected_to '/goxygene/parameters/bureau_consultant/article_topics'
      end

      it 'saves the name field' do
        assert_equal topic_name, topic.reload.name
      end

      it 'saves the description field' do
        assert_equal description, topic.reload.description
      end
    end

    describe 'when destroying a topic' do
      it 'removes the topic from database' do
        assert_difference 'Goxygene::ArticleTopic.count', -1 do
          delete "/goxygene/parameters/bureau_consultant/article_topics/#{topic.id}"
        end
      end

      it 'redirects to the topics page' do
        delete "/goxygene/parameters/bureau_consultant/article_topics/#{topic.id}"

        assert_redirected_to '/goxygene/parameters/bureau_consultant/article_topics'
      end
    end

    describe 'when displaying the new page' do
      it 'renders the page' do
        get "/goxygene/parameters/bureau_consultant/article_topics/new"

        assert_response :success
      end
    end

    describe 'when creating a topic' do
      let(:topic) { Goxygene::ArticleTopic.last }

      def post_create_topic
        post "/goxygene/parameters/bureau_consultant/article_topics", params: {
          article_topic: {
            name:        topic_name,
            description: description
          }
        }
      end

      it 'creates a new entry in database' do
        assert_difference 'Goxygene::ArticleTopic.count' do
          post_create_topic
        end
      end

      it 'redirects to the topics list' do
        post_create_topic
        assert_redirected_to '/goxygene/parameters/bureau_consultant/article_topics'
      end

      it 'saves the name field' do
        post_create_topic
        assert_equal topic_name, topic.reload.name
      end

      it 'saves the description field' do
        post_create_topic
        assert_equal description, topic.reload.description
      end
    end

  end

  describe 'not authenticated' do
    describe 'when listing topics' do
      it 'redirects to the authentication page' do
        get '/goxygene/parameters/bureau_consultant/article_topics'
        assert_redirected_to '/cas_authentications/sign_in'
      end
    end
  end
end
