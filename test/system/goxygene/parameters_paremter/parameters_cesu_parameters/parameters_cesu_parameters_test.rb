require "application_system_test_case"
require "goxygene_set_up"

class ParametersCesuParametersTest < GoxygeneSetUp

  test "Should open a cesu parameters edit" do
    visit goxygene.cesu_parameters_path
    find('tr:first-child a[href*="/edit"]').click
    click_on "Enregistrer"
    assert_selector ".inscription-menus li.active a", text: "Paramètres CESU"
  end

  test "Should open a cesu parameters create form" do
    visit goxygene.cesu_parameters_path
    click_on "Ajouter un paramètre CESU"

    fill_in "parameter[valid_from]", with: "31/12/2020"
    find('#parameter_value').click
    fill_in "parameter[value]", with: "10"
    select "CESU : Coût unitaire du chèque - CESU_CHECK_COST", from: "parameter[code]"

    click_on "Enregistrer"

    assert_selector ".inscription-menus li.active a", text: "Paramètres CESU"
  end
end
