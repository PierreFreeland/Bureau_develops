require "application_system_test_case"
require "goxygene_set_up"

class ParametersOtherParametersTest < GoxygeneSetUp

  test "Should open a other parameters edit" do
    visit goxygene.other_parameters_path
    find('tr:first-child a[href*="/edit"]').click
    click_on "Enregistrer"
    assert_selector ".inscription-menus li.active a", text: "Autres paramètres"
  end

  test "Should open a other parameters create form" do
    visit goxygene.other_parameters_path
    click_on "Ajouter un nouveau autre paramètre"

    fill_in "parameter[valid_from]", with: "31/12/2020"
    find('#parameter_value').click
    fill_in "parameter[value]", with: "10"
    select "Taux apporteur d'affaires - BUSINESS_FINDER_RATE", from: "parameter[code]"

    click_on "Enregistrer"

    assert_selector ".inscription-menus li.active a", text: "Autres paramètres"
  end
end
