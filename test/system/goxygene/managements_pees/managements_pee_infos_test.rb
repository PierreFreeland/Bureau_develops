require "application_system_test_case"
require "goxygene_set_up"

class ManagementsPeeInfosTest < GoxygeneSetUp

  test "Should show create pee form when click Ajouter un PEE" do
    visit goxygene.managements_pees_path
    click_on "Ajouter un PEE"
    assert_selector "#create-pee.panel.collapse.in"
  end

  test "Should show filter pee when click Filtres" do
    visit goxygene.managements_pees_path
    click_on "Filtres"
    assert_selector "#filter-search.panel.collapse.in"
  end

  test "Should sort asc Code paie when click Code paie" do
    visit goxygene.managements_pees_path
    click_on "Code paie"
    assert_selector ".sort_link.asc", text: "CODE PAIE ▲"
  end

  test "Should sort asc Consultant when click Consultant" do
    ActiveRecord::Migration.enable_extension "unaccent"
    visit goxygene.managements_pees_path
    find('.sort_link[href*="consultant_individual_full_name"]').click
    assert_selector ".sort_link.asc", text: "CONSULTANT ▲"
  end

  test "Should sort asc Société when click Société" do
    visit goxygene.managements_pees_path
    click_on "Société"
    assert_selector ".sort_link.asc", text: "SOCIÉTÉ ▲"
  end

  test "Should sort asc Versement volontaire when click Versement volontaire" do
    visit goxygene.managements_pees_path
    click_on "Versement volontaire"
    assert_selector ".sort_link.asc", text: "VERSEMENT VOLONTAIRE ▲"
  end

  test "Should sort asc Abondement brut when click Abondement brut" do
    visit goxygene.managements_pees_path
    click_on "Abondement brut"
    assert_selector ".sort_link.asc", text: "ABONDEMENT BRUT ▲"
  end

  test "Should sort asc CSG sur Abondement when click CSG sur Abondement" do
    visit goxygene.managements_pees_path
    click_on "CSG sur Abondement"
    assert_selector ".sort_link.asc", text: "CSG SUR ABONDEMENT ▲"
  end

  test "Should sort asc Abondement net when click Abondement net" do
    visit goxygene.managements_pees_path
    click_on "Abondement net"
    assert_selector ".sort_link.asc", text: "ABONDEMENT NET ▲"
  end

  test "Should sort asc Investissement when click Investissement" do
    visit goxygene.managements_pees_path
    click_on "Investissement"
    assert_selector ".sort_link.asc", text: "INVESTISSEMENT ▲"
  end

  test "Should sort asc Date de versement when click Date de versement" do
    visit goxygene.managements_pees_path
    click_on "Date de versement"
    assert_selector ".sort_link.asc", text: "DATE DE VERSEMENT ▲"
  end

  test "Should sort asc Forfait social when click Date de Forfait social" do
    visit goxygene.managements_pees_path
    click_on "Forfait social"
    assert_selector ".sort_link.asc", text: "FORFAIT SOCIAL ▲"
  end

  test "Should sort asc Créé le when click Date de Créé le" do
    visit goxygene.managements_pees_path
    click_on "Créé le"
    assert_selector ".sort_link.asc", text: "CRÉÉ LE ▲"
  end

  test "Should sort asc Créé par when click Date de Créé par" do
    visit goxygene.managements_pees_path
    click_on "Créé par"
    assert_selector ".sort_link.asc", text: "CRÉÉ PAR ▲"
  end

  test "Should go to consultant timeline when click consultant name" do
    visit goxygene.managements_pees_path
    find('tr:first-child a[href*="/consultants/"]').click
    assert_selector "li.active", text: "TIMELINE"
  end

  test "Should open edit modal when click edit icon" do
    visit goxygene.managements_pees_path
    find('tr:first-child a[href*="/edit"]').click
    assert_selector "h4", text: "Loading..."
    sleep(4)
    click_on "Enregistrer"
    sleep(1)
  end

  test "Should have results when filter with date of versement" do
    visit goxygene.managements_pees_path
    click_on "Filtres"
    fill_in "q[deposit_date_gteq]", with: "01/01/2020"
    click_on "Filtres"
    fill_in "q[deposit_date_lteq]", with: "31/12/2020"
    assert_selector "div#pee-lists"
  end

  test "Create new pee with payroll code" do
    visit goxygene.managements_pees_path
    click_on "Ajouter un PEE"

    find('#select2-company_saving_plan_deposit_consultant_id-container').click
    find(:css, "input[class$='select2-search__field']").set("08786")

    sleep(1)
    find('ul:first-child li[role*="treeitem"]').click

    fill_in "company_saving_plan_deposit[deposit_amount]", with: "100"

    select "AMUNDI ACTIONS INTERNATIONALES ESR", from: "company_saving_plan_deposit[company_saving_plan_deposit_lines_attributes][0][company_saving_plan_fund_id]"
    fill_in "company_saving_plan_deposit[company_saving_plan_deposit_lines_attributes][0][rate]", with: "100"

    click_on "Enregistrer"

    assert_selector "div#pee-lists"
    assert_selector "div#pee-lists td", text: "08786"
  end

  test "Delete a pee" do
    visit goxygene.managements_pees_path
    find('tr:first-child a[href*="/batch_delete"]').click
    page.driver.browser.switch_to.alert.accept
    sleep 1
    assert_selector "h4", text: "PLAN EPARGNE ENTREPRISE (PEE)"
  end

  test "Should select all checkbox and delete all" do
    visit goxygene.managements_pees_path
    find("#check-all.no-edit", visible: false).set(true)
    click_on 'Supprimer'
    page.driver.browser.switch_to.alert.accept
    sleep 1
    assert_selector "h4", text: "PLAN EPARGNE ENTREPRISE (PEE)"
  end

  test "click excel icon" do
    visit goxygene.managements_pees_path
    page.execute_script('$.find(".text-green")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH+"/managements_pees.xlsx"
    assert File.exist?(full_path)
  end
end
