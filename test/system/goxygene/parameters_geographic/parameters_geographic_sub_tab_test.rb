require "application_system_test_case"
require "goxygene_set_up"

class ParametersGeographicSubtabTest < GoxygeneSetUp

  setup do
    visit goxygene.countries_path
  end

  test "Should redirect to countries" do
    assert_selector "h4", "PAYS"
  end

  test "Should redirect to regions" do
    within ".inscription-menus" do
      all('li')[1].click
    end
    assert_selector "h4", "RÉGIONS"
  end

  test "Should redirect to departments" do
    within ".inscription-menus" do
      all('li')[2].click
    end
    assert_selector "h4", " DÉPARTEMENTS"
  end

end
