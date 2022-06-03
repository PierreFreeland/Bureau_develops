require 'test_helper'

describe Goxygene::ParametersDocumentationCategoriesController do

  describe 'authenticated as an administrator' do

    let(:category)      { Goxygene::DocumentationCategory.all.shuffle.first }
    let(:category_name) { FFaker::Lorem.words(5).join(' ')                  }
    let(:description)   { FFaker::Lorem.words(250).join(' ')                }

    before do
      sign_in cas_authentications(:administrator)
    end

    describe 'when listing categories' do
      before { get '/goxygene/parameters/bureau_consultant/documentation_categories' }

      it 'renders the page' do
        assert_response :success
      end

      it 'displays pagination links' do
        skip if Goxygene::DocumentationCategory.count < 25
        assert_select 'nav.pagination'
      end

      it 'displays multiple items' do
        assert_select 'tbody tr.category', Goxygene::DocumentationCategory.count
      end

      it 'displays a deletion link' do
        assert_select 'tr.category td.actions a.destroy', Goxygene::DocumentationCategory.count
      end
    end

    describe 'when editing a category' do
      before { get "/goxygene/parameters/bureau_consultant/documentation_categories/#{category.id}" }

      it 'renders the page' do
        assert_response :success
      end

      it 'includes a form to edit the category' do
        assert_select 'form'
      end

      it 'includes a field for the name' do
        assert_select 'form input[type="text"][name="documentation_category[name]"]'
      end

      it 'includes a field for the description' do
        assert_select 'form textarea[name="documentation_category[description]"]'
      end
    end

    describe 'when updating a category' do
      before do
        patch "/goxygene/parameters/bureau_consultant/documentation_categories/#{category.id}", params: {
          documentation_category: {
            name:        category_name,
            description: description
          }
        }
      end

      it 'redirects to the categories list' do
        assert_redirected_to '/goxygene/parameters/bureau_consultant/documentation_categories'
      end

      it 'saves the name field' do
        assert_equal category_name, category.reload.name
      end

      it 'saves the description field' do
        assert_equal description, category.reload.description
      end
    end

    describe 'when destroying a category' do
      it 'removes the category from database' do
        assert_difference 'Goxygene::DocumentationCategory.count', -1 do
          delete "/goxygene/parameters/bureau_consultant/documentation_categories/#{category.id}"
        end
      end

      it 'redirects to the categories page' do
        delete "/goxygene/parameters/bureau_consultant/documentation_categories/#{category.id}"

        assert_redirected_to '/goxygene/parameters/bureau_consultant/documentation_categories'
      end
    end

    describe 'when displaying the new page' do
      it 'renders the page' do
        get "/goxygene/parameters/bureau_consultant/documentation_categories/new"

        assert_response :success
      end
    end

    describe 'when creating a category' do
      let(:category) { Goxygene::DocumentationCategory.last }

      def post_create_category
        post "/goxygene/parameters/bureau_consultant/documentation_categories", params: {
          documentation_category: {
            name:        category_name,
            description: description
          }
        }
      end

      it 'creates a new entry in database' do
        assert_difference 'Goxygene::DocumentationCategory.count' do
          post_create_category
        end
      end

      it 'redirects to the categories list' do
        post_create_category
        assert_redirected_to '/goxygene/parameters/bureau_consultant/documentation_categories'
      end

      it 'saves the name field' do
        post_create_category
        assert_equal category_name, category.reload.name
      end

      it 'saves the description field' do
        post_create_category
        assert_equal description, category.reload.description
      end
    end

  end

  describe 'not authenticated' do
    describe 'when listing categories' do
      it 'redirects to the authentication page' do
        get '/goxygene/parameters/bureau_consultant/documentation_categories'
        assert_redirected_to '/cas_authentications/sign_in'
      end
    end
  end
end
