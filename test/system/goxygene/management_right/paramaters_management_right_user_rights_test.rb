require "application_system_test_case"
require "goxygene_set_up"
require 'api_accountancy'

class ParametersManagementRightUserRightsTest < GoxygeneSetUp

  setup do
    ActiveRecord::Migration.enable_extension "unaccent"
    visit goxygene.user_rights_path
  end

  test "Should redirect to new management right user rights page" do
    click_on "Ajouter un utillisateur"
    assert_selector "h4", text: "Ajouter un utillisateur"
  end

  test "Should show filter section" do
    click_on "Filtres"
    assert_selector "label", text: "Utilisateur"
  end

  test "Should show result of filter from section" do
    click_on "Filtres"
    fill_in 'q[individual_full_name_cont]', with: "#{Goxygene::Parameter.value_for_group}"
    click_on "Rechercher"
    sleep 1
    assert_selector ".inscription-menus li.active a", text: "Droits utilisateurs"
  end

  test "select list a user right" do
    user_selector = find(".menu-msg li:nth-child(2) a")["text"]
    find('ul.menu-msg li:nth-child(2)').click
    assert_selector ".menu-msg li.active a", text: user_selector
  end

  test "Should select access level and submit" do
    select "Comptabilisation", from: "employee[employee_accesses_attributes][0][access_level_id]", visible: false
    click_on "Enregistrer"
    assert_selector ".inscription-menus li.active a", text: "Droits utilisateurs"
  end

  test "Should show error message when submit a wrong info" do
    click_on "Ajouter un utillisateur"
    click_on "Enregistrer"

    assert_selector "li", text: "Le champ Email doit être précisé"
    assert_selector "li", text: "Nom doit être rempli(e)"
    assert_selector "li", text: "Prénom doit être rempli(e)"
  end

  test "Should show error message when not fill a last name" do
    click_on "Ajouter un utillisateur"
    fill_in "employee[individual_attributes][last_name]", with: "Test"
    fill_in "employee[contact_datum_attributes][email]", with: "Test@mail.com"
    click_on "Enregistrer"

    assert_selector "li", text: "Prénom doit être rempli(e)"
  end

  test "Should show error message when not fill a name" do
    click_on "Ajouter un utillisateur"
    fill_in "employee[individual_attributes][first_name]", with: "User"
    fill_in "employee[contact_datum_attributes][email]", with: "Test@mail.com"
    click_on "Enregistrer"

    assert_selector "li", text: "Nom doit être rempli(e)"
  end

  test "Should show error message when not fill a email" do
    click_on "Ajouter un utillisateur"
    fill_in "employee[individual_attributes][last_name]", with: "Test"
    fill_in "employee[individual_attributes][first_name]", with: "User"
    click_on "Enregistrer"

    assert_selector "li", text: "Le champ Email doit être précisé"
  end

  test "Should success for create a user rights" do
    click_on "Ajouter un utillisateur"
    fill_in "employee[individual_attributes][last_name]", with: "Test"
    fill_in "employee[individual_attributes][first_name]", with: "User"
    fill_in "employee[contact_datum_attributes][email]", with: "Test@mail.com"
    click_on "Enregistrer"
    sleep 2
    assert_selector ".menu-msg li.active a", text: "Test User"
  end
end
