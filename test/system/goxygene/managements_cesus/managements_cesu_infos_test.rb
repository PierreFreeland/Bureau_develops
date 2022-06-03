require "application_system_test_case"
require "goxygene_set_up"

class ManagementsCesuInfosTest < GoxygeneSetUp

  test "Should show create cesu form when click Ajouter un CESU" do
    visit goxygene.managements_cesus_path
    click_on "Ajouter un CESU"
    assert_selector "#create-cesu.panel.collapse.in"
  end

  test "Should show filter cesu when click Filtres" do
    visit goxygene.managements_cesus_path
    click_on "Filtres"
    assert_selector "#filter-search.panel.collapse.in"
  end

  test "Should sort asc Code paie when click Code paie" do
    visit goxygene.managements_cesus_path
    click_on "Code paie"
    assert_selector ".sort_link.asc", text: "CODE PAIE ▲"
  end

  test "Should sort asc Consultant when click Consultant" do
    ActiveRecord::Migration.enable_extension "unaccent"
    visit goxygene.managements_cesus_path
    find('.sort_link[href*="consultant_individual_full_name"]').click
    assert_selector ".sort_link.asc", text: "CONSULTANT ▲"
  end

  test "Should sort asc SOCIÉTÉ when click SOCIÉTÉ" do
    visit goxygene.managements_cesus_path
    click_on "SOCIÉTÉ"
    assert_selector ".sort_link.asc", text: "SOCIÉTÉ ▲"
  end

  test "Should sort asc ETAT when click ETAT" do
    visit goxygene.managements_cesus_path
    click_on "ETAT"
    assert_selector ".sort_link.asc", text: "ETAT ▲"
  end

  test "Should sort asc e-CESU when click e-CESU" do
    visit goxygene.managements_cesus_path
    click_on "e-CESU"
    assert_selector ".sort_link.asc", text: "E-CESU ▲"
  end

  test "Should sort asc NOMBRE DE CHÈQUES CESU when click NOMBRE DE CHÈQUES CESU" do
    visit goxygene.managements_cesus_path
    click_on "NOMBRE DE CHÈQUES CESU"
    assert_selector ".sort_link.asc", text: "NOMBRE DE CHÈQUES CESU ▲"
  end

  test "Should sort asc MONTANT when click MONTANT" do
    visit goxygene.managements_cesus_path
    click_on "MONTANT"
    assert_selector ".sort_link.asc", text: "MONTANT ▲"
  end

  test "Should sort asc FRAIS DE FABRICATION when click FRAIS DE FABRICATION" do
    visit goxygene.managements_cesus_path
    click_on "FRAIS DE FABRICATION"
    assert_selector ".sort_link.asc", text: "FRAIS DE FABRICATION ▲"
  end

  test "Should sort asc Créé le when click Date de Créé le" do
    visit goxygene.managements_cesus_path
    click_on "CRÉÉ LE"
    assert_selector ".sort_link.asc", text: "CRÉÉ LE ▲"
  end

  test "Should sort asc Créé par when click Date de Créé par" do
    ActiveRecord::Migration.enable_extension "unaccent"
    visit goxygene.managements_cesus_path
    click_on "CRÉÉ PAR"
    assert_selector ".sort_link.asc", text: "CRÉÉ PAR ▲"
  end

  test "Should go to consultant timeline when click consultant name" do
    visit goxygene.managements_cesus_path
    find('tr:first-child a[href*="/consultants/"]').click
    assert_selector "li.active", text: "TIMELINE"
  end

  test "Should open edit modal when click edit icon" do
    visit goxygene.managements_cesus_path
    find('tr:first-child a[href*="/edit"]').click
    assert_selector "h4", text: "Loading..."
    sleep(4)
    click_on "Enregistrer"
    sleep(1)
  end

  test "Should have results when filter with date of created" do
    visit goxygene.managements_cesus_path
    click_on "Filtres"
    fill_in "q[created_at_gteq]", with: "01/01/2020"
    click_on "Filtres"
    fill_in "q[created_at_lteq]", with: "31/12/2020"
    assert_selector "div#cesu-lists"
  end

  test "Delete a cesu" do
    visit goxygene.managements_cesus_path
    find('tr:first-child a[data-method*="delete"]').click
    page.driver.browser.switch_to.alert.accept
    sleep 1
    assert_selector "h4", text: "CESU"
  end

  test "Should select all checkbox and delete all" do
    visit goxygene.managements_cesus_path
    find("#check-all.no-edit", visible: false).set(true)
    click_on 'Supprimer'
    page.driver.browser.switch_to.alert.accept
    sleep 1
    assert_selector "h4", text: "CESU"
  end

  test "Create new cesu with payroll code" do
    file_path = File.absolute_path('./test/fixtures/files/sample_document.pdf')
    visit goxygene.managements_cesus_path
    click_on "Ajouter un CESU"

    find('#select2-cesu_command_consultant_id-container').click
    find(:css, "input[class$='select2-search__field']").set("08388")

    sleep 1
    find('ul:first-child li[role*="treeitem"]').click

    fill_in 'cesu_command[number_of_checks]', with: "100"
    find("#cesu_command_ecesu_title", visible: false).set(true)
    attach_file('cesu_command[document_attributes][filename]', file_path)

    click_on "Enregistrer"
    sleep 2
    assert_selector "div#cesu-lists"
    assert_selector "div#cesu-lists td", text: "08388"
  end

  test "click excel icon" do
    visit goxygene.managements_cesus_path
    page.execute_script('$.find(".text-green")[0].click()')
    sleep 3
    full_path = DOWNLOAD_PATH+"/managements_cesus.xlsx"
    assert File.exist?(full_path)
  end
end
