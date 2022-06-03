require "application_system_test_case"
require "goxygene_set_up"

class ParametersDocumentationCategoriesTest < GoxygeneSetUp

  setup do
    visit goxygene.documentation_categories_path
  end

  test "Should create new documentation category" do
    page.find(".fa-plus-circle").click
    fill_in "documentation_category_name", with: "Test title"
    click_on "Enregistrer cette rubrique"
    if has_css?("a", text: "Fin »")
      sleep 1
      click_on "Fin"
    end

    assert_selector "td", "Test title"
  end

  test "Should redirect to documentation category detail page" do
    title = all(".name a").first.text
    all(".name a").first.click
    assert_selector "h4", title
  end

  test "Should update documentation category data"do
    all(".name a").first.click
    fill_in "documentation_category_name", with: "Test update title"
    click_on "Enregistrer cette rubrique"

    if has_css?("a", text: "Fin »")
      click_on "Fin"
      sleep 1
    end

    assert_selector "td", "Test update title"
  end

  test "Should delete article topic" do
    before = Goxygene::DocumentationCategory.count
    all('.destroy').first.click
    assert_equal before-1, Goxygene::DocumentationCategory.count
  end
end

