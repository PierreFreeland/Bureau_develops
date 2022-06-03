require "application_system_test_case"
require "goxygene_set_up"

class ManagementsExpensesSubTabTest < GoxygeneSetUp

  setup do
    visit goxygene.managements_expenses_path
  end

  test "Should redirect to managements expenses da" do
    assert_selector "h4", "DÉCLARATION D'ACTIVITÉ"
  end

  test "Should redirect to managements expenses ndf" do
    within ".inscription-menus" do
      all('li')[1].click
    end
    assert_selector "h4", "NDF"
  end

  test "Should redirect to managements expenses df requests" do
    within ".inscription-menus" do
      all('li')[2].click
    end
    assert_selector "h4", "DEMANDES DF"
  end

  test "Should redirect to managements expenses df" do
    within ".inscription-menus" do
      all('li')[3].click
    end
    assert_selector "h4", "DF"
  end

  test "Should redirect to managements expenses simplified validations" do
    within ".inscription-menus" do
      all('li')[4].click
    end
    assert_selector "h4", "VALIDATION SIMPLIFIÉE DES FRAIS"
  end
end
