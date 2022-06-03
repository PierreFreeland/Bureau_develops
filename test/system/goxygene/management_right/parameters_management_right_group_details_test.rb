require "application_system_test_case"
require "goxygene_set_up"
require 'api_accountancy'

class ParametersManagementRightGroupDetailsTest < GoxygeneSetUp

  setup do
    ActiveRecord::Migration.enable_extension "unaccent"
    visit goxygene.group_details_path
  end

  test "Should redirect to new group page" do
    click_on "Ajouter un groupe"
    assert_selector "h4", text: "Ajouter un groupe"
  end

  test "Should show filter section" do
    click_on "Filtres"
    assert_selector "label", text: "Que les actifs"
  end

  test "Should filter with Utilisateur" do
    group_name = find('.menu-msg li:first-child a')['text'][0, 3]

    click_on "Filtres"
    fill_in "q[name_cont]", with: group_name
    click_on 'Rechercher'
    sleep 2

    assert_selector ".menu-msg li:first-child", text: group_name
  end

  test "select list of user detail" do
    group_name = find(".menu-msg li:nth-child(2) a")["text"]
    find(".menu-msg li:nth-child(2) a").click
    assert_selector ".menu-msg li.active a", text: group_name
  end

  test "Should create a user" do
    click_on "Ajouter un groupe"
    find("#new_employee_role #employee_role_name").set("TestRole")
    click_on "Enregistrer"
    sleep 1
    assert_selector ".menu-msg li a", text: "TestRole"
  end

  test "Should show a error message when not fill role name" do
    click_on "Ajouter un groupe"
    click_on "Enregistrer"
    sleep 1
    assert_selector "li", text: "Le champ nom doit être renseigné."
  end

  test "Should can submit when select one of right other user" do
    first_selector = find('#multiselect_group_to option:first-child', visible: false)['text']
    find('#multiselect_group_to option:first-child').click
    click_button 'multiselect_group_leftSelected'
    click_on 'Enregistrer'
    sleep 1
    assert_selector "#multiselect_group option", text: first_selector
  end

  test "Should can submit when select one of left other user" do
    first_selector = find('#multiselect_group option:first-child', visible: false)['text']
    click_button 'multiselect_group_rightSelected'
    click_on 'Enregistrer'
    sleep 1
    assert_selector "#multiselect_group_to option", text: first_selector
  end

  test "Should can submit when select all of right other group" do
    first_selector = find('#multiselect_group_to option:first-child', visible: false)['text']
    click_button 'multiselect_group_leftAll'
    click_on 'Enregistrer'
    sleep 1
    assert_selector "#multiselect_group option", text: first_selector
  end

  test "Should can submit when select all of left other group" do
    first_selector = find('#multiselect_group option:first-child', visible: false)['text']
    click_button 'multiselect_group_rightAll'
    click_on 'Enregistrer'
    sleep 1
    assert_selector "#multiselect_group_to option", text: first_selector
  end

  test "excel export" do
    page.execute_script('$.find(".text-green")[0].click()')
    sleep 1
    full_path = DOWNLOAD_PATH+"/export_users.xlsx"
    assert File.exist?(full_path)
  end
end
