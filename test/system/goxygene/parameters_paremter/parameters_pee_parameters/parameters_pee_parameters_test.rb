require "application_system_test_case"
require "goxygene_set_up"

class ParametersPeeParametersTest < GoxygeneSetUp

  test "Should open a pee parameters edit" do
    visit goxygene.pee_parameters_path
    find('tr:first-child a[href*="/edit"]').click
    click_on "Enregistrer"
    assert_selector ".inscription-menus li.active a", text: "Paramètres PEE"
  end

  test "Should open a pee parameters create form" do
    visit goxygene.pee_parameters_path
    click_on "Ajouter un paramètre PEE"

    fill_in "parameter[valid_from]", with: "31/12/2020"
    find('#parameter_value').click
    fill_in "parameter[value]", with: "10"
    select "PEE_MAX_CONTRIBUTION", from: "parameter[code]"

    click_on "Enregistrer"

    assert_selector ".inscription-menus li.active a", text: "Paramètres PEE"
  end
end
