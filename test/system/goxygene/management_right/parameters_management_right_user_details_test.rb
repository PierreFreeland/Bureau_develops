require "application_system_test_case"
require "goxygene_set_up"
require 'api_accountancy'

class ParametersManagementRightUserDetailsTest < GoxygeneSetUp

  setup do
    ActiveRecord::Migration.enable_extension "unaccent"
    visit goxygene.user_details_path
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
    find('.employee-individual-show #employee_individual_attributes_last_name').set("Test")
    find('#new_employee #employee_contact_datum_attributes_email').set("Test@mail.com")
    click_on "Enregistrer"

    assert_selector "li", text: "Prénom doit être rempli(e)"
  end

  test "Should show error message when not fill a name" do
    click_on "Ajouter un utillisateur"
    find('.employee-individual-show #employee_individual_attributes_first_name').set("User")
    find('#new_employee #employee_contact_datum_attributes_email').set("Test@mail.com")
    click_on "Enregistrer"

    assert_selector "li", text: "Nom doit être rempli(e)"
  end

  test "Should show error message when not fill a email" do
    click_on "Ajouter un utillisateur"
    find('.employee-individual-show #employee_individual_attributes_last_name').set("Test")
    find('.employee-individual-show #employee_individual_attributes_first_name').set("User")
    click_on "Enregistrer"

    assert_selector "li", text: "Le champ Email doit être précisé"
  end

  test "Should success for create a user rights" do
    click_on "Ajouter un utillisateur"
    find('.employee-individual-show #employee_individual_attributes_last_name').set("Test")
    find('.employee-individual-show #employee_individual_attributes_first_name').set("User")
    find('#new_employee #employee_contact_datum_attributes_email').set("Test@mail.com")
    click_on "Enregistrer"
    sleep 2
    assert_selector ".menu-msg li.active a", text: "Test User"
  end

  test "Should redirect to new management right page" do
    click_on "Ajouter un utillisateur"
    assert_selector "h4", text: "Ajouter un utillisateur"
  end

  test "Should show filter section" do
    click_on "Filtres"
    assert_selector "label", text: "Utilisateur"
  end

  test "Should filter with Utilisateur" do
    first_user = find('.menu-msg li:first-child a')['text'][0, 3]

    click_on "Filtres"
    fill_in "q[individual_full_name_cont]", with: first_user
    click_on 'Rechercher'
    sleep 2

    assert_selector ".menu-msg li:first-child", text: first_user
  end

  test "Should show name when choose" do
    page.all('li')[1].click
    assert_equal find('#employee_individual_attributes_last_name').value, page.all('li')[1].text.split(" ").first
  end

  test "Should can submit when select one of right other group" do
    first_selector = find('#multiselect_user_to option:first-child', visible: false)['text']
    find('#multiselect_user_to option:first-child').click
    click_button 'multiselect_user_leftSelected'
    click_on 'Enregistrer'
    sleep 1
    assert_selector "#multiselect_user option", text: first_selector
  end

  test "Should can submit when select one of left other group" do
    first_selector = find('#multiselect_user option:first-child', visible: false)['text']
    click_button 'multiselect_user_rightSelected'
    click_button 'multiselect_user_rightSelected'
    click_on 'Enregistrer'
    sleep 1
    assert_selector "#multiselect_user_to option", text: first_selector
  end

  test "Should can submit when select all of right other group" do
    first_selector = find('#multiselect_user_to option:first-child', visible: false)['text']
    click_button 'multiselect_user_leftAll'
    click_on 'Enregistrer'
    sleep 1
    assert_selector "#multiselect_user option", text: first_selector
  end

  test "Should can submit when select all of left other group" do
    first_selector = find('#multiselect_user option:first-child', visible: false)['text']
    click_button 'multiselect_user_rightAll'
    click_on 'Enregistrer'
    sleep 1
    assert_selector "#multiselect_user_to option", text: first_selector
  end

  test "select list of user detail" do
    page.all('li')[1].click
    page.all('li')[1].has_css?('.active')
  end

  test "excel export" do
    page.execute_script('$.find(".text-green")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH+"/export_users.xlsx"
    assert File.exist?(full_path)
  end
end
