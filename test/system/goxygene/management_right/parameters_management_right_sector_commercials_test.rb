require "application_system_test_case"
require "goxygene_set_up"
require 'api_accountancy'

class ParametersManagementSectorCommercialsTest < GoxygeneSetUp

  setup do
    ActiveRecord::Migration.enable_extension "unaccent"
    visit goxygene.sector_commercials_path
  end

  test "Should redirect to new management right page" do
    click_on "Ajouter un secteur"
    assert_selector "h4", text: "Créer un secteur commercial"
  end

  test "Should show filter section" do
    click_on "Filtres"
    assert_selector "label", text: "Nom du secteur"
  end

  test "Should show result of filter from section" do
    first_user = find('.menu-msg li:first-child a')['text'][0, 3]
    click_on "Filtres"
    fill_in 'q[label_cont]', with: first_user
    click_on "Rechercher"
    sleep 1
    assert_selector ".menu-msg li a", text: first_user
  end

  test "select list a user right" do
    user_selector = find(".menu-msg li:nth-child(2) a")["text"]
    find('.menu-msg li:nth-child(2) a').click
    sleep 3
    assert_selector ".menu-msg li.active a", text: user_selector
  end

  test "Should show error message when submit a wrong info" do
    click_on "Ajouter un secteur"
    find('#modal-lg input[value*="Enregistrer"]').click

    assert_selector "li", text: "Délégué doit exister"
    assert_selector "li", text: "Le champ Email doit être précisé"
  end

  test "Should create a sector" do
    click_on "Ajouter un secteur"
    find('#modal-lg #area_label').set("Test")

    find("#modal-lg #select2-area_employee_id-container").click
    find(:css, "input[class$='select2-search__field']").set("#{Goxygene::Parameter.value_for_group}")

    sleep 1
    find('li.select2-results__option[role*="treeitem"]:first-child').click

    find("#modal-lg #area_contact_datum_attributes_email").set("Test@itg.com")
    find('#modal-lg input[value*="Enregistrer"]').click

    sleep 2
    assert_selector ".menu-msg li a", text: "Test"
  end

  test "Should success for submit a selected region" do
    sleep 3
    find('div.jstree_div ul.jstree-container-ul li:first-child a').click
    page.driver.browser.switch_to.alert.accept
    sleep 3
    assert_selector 'div.jstree_div ul.jstree-container-ul li:first-child[aria-selected*="true"]'
  end

  test "Should can edit a sector" do
    find('#area_label').set("Test AURO")

    find("#select2-area_employee_id-container").click
    find(:css, "input[class$='select2-search__field']").set("#{Goxygene::Parameter.value_for_group}")

    sleep 1
    find('li.select2-results__option[role*="treeitem"]:first-child').click

    find("#area_contact_datum_attributes_email").set("Test@itg.com")
    click_on "Enregistrer"
    page.driver.browser.navigate.refresh
    assert_text "Test AURO"
  end
end
