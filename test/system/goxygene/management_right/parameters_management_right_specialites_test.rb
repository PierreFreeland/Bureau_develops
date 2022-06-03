require "application_system_test_case"
require "goxygene_set_up"
require 'api_accountancy'

class ParametersManagementRightSpecialitesTest < GoxygeneSetUp

  setup do
    visit goxygene.specialites_path
  end

  test "Should show error message when not fill data in create form of speciality" do
    click_on "Ajouter une spécialité"
    click_on "Enregistrer"

    assert_text "Spécialité doit être rempli(e)"
    assert_text "Conseiller par défaut doit être rempli(e)"
  end

  test "Should create a new speciality" do
    click_on "Ajouter une spécialité"

    select find('#modal option:nth-child(2)')['text'], from: "consultant_activity[employee_id]"
    fill_in 'consultant_activity[label]', with: 'Testing Speciality'

    click_on "Enregistrer"

    assert_text "Testing Speciality"
  end

  test "Should sort asc Spécialité when click Spécialité" do
    click_on "Spécialité"
    assert_selector ".sort_link.asc", text: "SPÉCIALITÉ ▲"
  end

  test "Should show edit when click" do
    find('tbody tr:first-child a[href*="/edit"]').click

    find('#modal input#consultant_activity_active', visible: false).set(false)

    click_on "Enregistrer"
    assert_selector ".inscription-menus li.active", text: 'Spécialités'
  end
end
