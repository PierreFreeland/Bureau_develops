require "application_system_test_case"
require "goxygene_set_up"
require 'api_accountancy'

class ParametersManagementRightTest < GoxygeneSetUp

  setup do
    ActiveRecord::Migration.enable_extension "unaccent"
    visit goxygene.user_details_path
  end

  test "Should go to user details page" do
    find('.inscription-menus li.active a').click
    assert_selector ".inscription-menus li.active a", text: "Données utilisateurs"
  end

  test "Should go to user right page" do
    click_on "Droits utilisateurs"
    assert_selector ".inscription-menus li.active a", text: "Droits utilisateurs"
  end

  test "Should go to group details page" do
    click_on "Données groupes"
    assert_selector ".inscription-menus li.active a", text: "Données groupes"
  end

  test "Should go to group right page" do
    click_on "Droits groupes"
    assert_selector ".inscription-menus li.active a", text: "Droits groupes"
  end

  test "Should go to sector commercials page" do
    click_on "Secteurs commerciaux"
    assert_selector ".inscription-menus li.active a", text: "Secteurs commerciaux"
  end

  test "Should go to area offices page" do
    click_on "Bureaux"
    assert_selector ".inscription-menus li.active a", text: "Bureaux"
  end

  test "Should go to specialites page" do
    click_on "Spécialités"
    assert_selector ".inscription-menus li.active a", text: "Spécialités"
  end

  test "Should go to group consultants page" do
    click_on "Groupe de gestion"
    assert_selector ".inscription-menus li.active a", text: "Groupe de gestion"
  end

  test "Should go to user consultants page" do
    click_on "Affectations consultants"
    assert_selector ".inscription-menus li.active a", text: "Affectations consultants"
  end

end
