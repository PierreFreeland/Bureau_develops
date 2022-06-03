require "application_system_test_case"
require "goxygene_set_up"

class ParametersDevisesSubTabTest < GoxygeneSetUp

  setup do
    visit goxygene.devises_path
  end

  test "Should redirect to devises" do
    assert_selector "h4", "DEVISES"
  end

  test "Should redirect to exchange rate" do
    within ".inscription-menus" do
      all('li')[1].click
    end
    assert_selector "h4", "TAUX DE CHANGE"
  end
end
