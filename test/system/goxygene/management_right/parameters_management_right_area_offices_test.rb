require "application_system_test_case"
require "goxygene_set_up"
require 'api_accountancy'

class ParametersManagementRightAreaOfficesTest < GoxygeneSetUp

  setup do
    visit goxygene.area_offices_path
  end

  test "Should show a create of modal" do
    click_on "Ajouter un nouveau bureau"
    assert_selector "h4", text: "AJOUTER UN NOUVEAU BUREAU"
  end

  test "Should show error message when not fill data in create of modal" do
    click_on "Ajouter un nouveau bureau"
    click_on "Enregistrer"

    assert_selector "#modal-xl li", text: "Le champ Email doit être précisé"
    assert_selector "#modal-xl li", text: "Secteur commercial doit être rempli(e)"
  end

  test "Should create a new area office" do
    click_on "Ajouter un nouveau bureau"

    select "Hauts-de-France", from: "area_office_area_id"
    fill_in "area_office[contact_datum_attributes][email]", with: 'Test@itg.fr'

    click_on "Enregistrer"

    assert_selector "td", text: "Test@itg.fr"
  end

  test "Should sort asc Secteur commercial when click Secteur commercial" do
    click_on "Secteur commercial"
    assert_selector ".sort_link.asc", text: "SECTEUR COMMERCIAL ▲"
  end

  test "Should show edit of modal" do
    find('tbody tr:first-child a[href*="/edit"]').click
    sleep 3
    assert_selector "h4", text: "MODIFIER UN BUREAU"
  end

  test "Should delete a bureau" do
    find('tbody tr:first-child a[data-method*="delete"]').click
    page.driver.browser.switch_to.alert.accept
    assert_selector '.inscription-menus li.active', text: 'Bureaux'
  end
end
