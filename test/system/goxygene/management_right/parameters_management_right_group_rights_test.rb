require "application_system_test_case"
require "goxygene_set_up"
require 'api_accountancy'

class ParametersManagementRightGroupRightsTest < GoxygeneSetUp

  setup do
    ActiveRecord::Migration.enable_extension "unaccent"
    visit goxygene.group_rights_path
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

  test "select list a group detail" do
    group_selector = find(".menu-msg li:nth-child(2) a")["text"]
    find(".menu-msg li:nth-child(2) a").click
    assert_selector ".menu-msg li.active a", text: group_selector
  end

  test "Should select access level and submit" do
    select "Comptabilisation", from: "employee_role[employee_roles_accesses_attributes][0][access_level_id]", visible: false
    click_on "Enregistrer"
    assert_selector ".inscription-menus li.active a", text: "Droits groupes"
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
end
