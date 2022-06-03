require "application_system_test_case"
require "goxygene_set_up"

class ParametersDocumentationsTest < GoxygeneSetUp

  setup do
    visit goxygene.articles_path
  end

  test "Should redirect to articles" do
    assert_selector "h4", "ARTICLES"
  end

  test "Should redirect to article topics" do
    within ".inscription-menus" do
      all('li')[1].click
    end
    assert_selector "h4", "RUBRIQUES"
  end

  test "Should redirect to documentations" do
    within ".inscription-menus" do
      all('li')[2].click
    end
    assert_selector "h4", "DOCUMENTATIONS"
  end

  test "Should redirect to documentation categories" do
    within ".inscription-menus" do
      all('li')[3].click
    end
    assert_selector "h4", "RUBRIQUES"
  end

end
