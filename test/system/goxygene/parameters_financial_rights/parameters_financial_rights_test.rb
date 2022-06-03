require "application_system_test_case"
require "goxygene_set_up"

class ParametersFinancialRightsTest < GoxygeneSetUp
  setup do
    visit goxygene.prescribers_path
  end

  test "Should go to prescriber page when click Droits financiers PL" do
    find('.pull-right ul.inscription-menus li.active a').click
    assert_selector ".inscription-menus li.active a", text: "Droits financiers PL"
  end

  test "Should go to validate prescriber page when click Validation des droits PL" do
    click_on "Validation des droits PL"
    assert_selector ".inscription-menus li.active a", text: "Validation des droits PL"
  end

  test "Should go to prescriber histories page when click Historique des droits PL" do
    click_on "Historique des droits PL"
    assert_selector ".inscription-menus li.active a", text: "Historique des droits PL"
  end
end
