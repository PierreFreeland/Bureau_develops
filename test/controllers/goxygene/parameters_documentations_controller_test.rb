require 'test_helper'

describe Goxygene::ParametersDocumentationsController do

  describe 'authenticated as an administrator' do

    let(:documentation) { Goxygene::Documentation.all.shuffle.first }
    let(:title)         { FFaker::Lorem.words(5).join(' ')    }
    let(:text)          { FFaker::Lorem.words(5).join(' ')    }
    let(:state)         { [true, false].shuffle.first         }
    let(:categories)    { Goxygene::DocumentationCategory.all.shuffle }

    before do
      sign_in cas_authentications(:administrator)
    end

    describe 'when listing documentations' do
      before { get '/goxygene/parameters/bureau_consultant/documentations' }

      it 'renders the page' do
        assert_response :success
      end

      it 'displays pagination links' do
        assert_select 'nav.pagination'
      end

      it 'displays multiple items' do
        assert_select 'tbody tr.documentation', 25
      end

      it 'displays a deletion link' do
        assert_select 'tr.documentation td.actions a.destroy', 25
      end
    end

    describe 'when editing a documentation' do
      before { get "/goxygene/parameters/bureau_consultant/documentations/#{documentation.id}" }

      it 'renders the page' do
        assert_response :success
      end

      it 'includes a form to edit the article' do
        assert_select 'form'
      end

      it 'includes a field for the title' do
        assert_select 'form input[type="text"][name="documentation[title]"]'
      end

      it 'includes a field for the text' do
        assert_select 'form textarea[name="documentation[text]"]'
      end

      it 'includes a submit button' do
        assert_select 'form button[type="submit"]'
      end
    end

    describe 'when updating a documentation' do
      before do
        patch "/goxygene/parameters/bureau_consultant/documentations/#{documentation.id}", params: {
          documentation: {
            title:        title,
            text:         text,
            state:        state,
            category_ids: categories.collect(&:id)
          }
        }
      end

      it 'redirects to the documentations list' do
        assert_redirected_to '/goxygene/parameters/bureau_consultant/documentations'
      end

      it 'saves the title field' do
        assert_equal title, documentation.reload.title
      end

      it 'saves the text field' do
        assert_equal text, documentation.reload.text
      end

      it 'saves the state field' do
        assert_equal state, documentation.reload.state
      end

      it 'saves the categories' do
        assert_equal categories.sort_by(&:id), documentation.reload.categories.to_a.sort_by(&:id)
      end
    end

    describe 'when destroying a documentation' do
      it 'removes the documentation from database' do
        assert_difference 'Goxygene::Documentation.count', -1 do
          delete "/goxygene/parameters/bureau_consultant/documentations/#{documentation.id}"
        end
      end

      it 'redirects to the documentations page' do
        delete "/goxygene/parameters/bureau_consultant/documentations/#{documentation.id}"

        assert_redirected_to '/goxygene/parameters/bureau_consultant/documentations'
      end
    end

    describe 'when displaying the new page' do
      it 'renders the page' do
        get "/goxygene/parameters/bureau_consultant/documentations/new"

        assert_response :success
      end
    end

    describe 'when creating a documentation' do
      let(:documentation) { Goxygene::Documentation.last }

      def post_create_documentation
        post "/goxygene/parameters/bureau_consultant/documentations", params: {
          documentation: {
            title:         title,
            text:          text,
            state:         state,
            category_ids:  categories.collect(&:id)
          }
        }
      end

      it 'creates a new entry in database' do
        assert_difference 'Goxygene::Documentation.count' do
          post_create_documentation
        end
      end

      it 'redirects to the documentations list' do
        post_create_documentation
        assert_redirected_to '/goxygene/parameters/bureau_consultant/documentations'
      end

      it 'saves the title field' do
        post_create_documentation
        assert_equal title, documentation.reload.title
      end

      it 'saves the text field' do
        post_create_documentation
        assert_equal text, documentation.reload.text
      end

      it 'saves the state field' do
        post_create_documentation
        assert_equal state, documentation.reload.state
      end

      it 'saves the categories' do
        post_create_documentation
        assert_equal categories.sort_by(&:id), documentation.reload.categories.to_a.sort_by(&:id)
      end
    end

  end

  describe 'not authenticated' do
    describe 'when listing documentations' do
      it 'redirects to the authentication page' do
        get '/goxygene/parameters/bureau_consultant/documentations'
        assert_redirected_to '/cas_authentications/sign_in'
      end
    end
  end
end
