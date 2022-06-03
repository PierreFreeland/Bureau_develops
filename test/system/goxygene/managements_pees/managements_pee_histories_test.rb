require "application_system_test_case"
require "goxygene_set_up"

class ManagementsPeeHistoriesTest < GoxygeneSetUp

  test "Should go show filter pee when click Filtres" do
    visit goxygene.managements_pee_histories_path
    click_on "Filtres"
    assert_selector "#filter-search.panel.collapse.in"
  end

  test "Should sort asc Consultant when click Consultant" do
    ActiveRecord::Migration.enable_extension "unaccent"
    visit goxygene.managements_pee_histories_path
    find('.sort_link[href*="consultant_individual_full_name"]').click
    assert_selector ".sort_link.asc", text: "CONSULTANT ▲"
  end

  test "Should sort asc Société when click Société" do
    visit goxygene.managements_pee_histories_path
    click_on "Société"
    assert_selector ".sort_link.asc", text: "SOCIÉTÉ ▲"
  end

  test "Should sort asc Versement volontaire when click Versement volontaire" do
    visit goxygene.managements_pee_histories_path
    click_on "Versement volontaire"
    assert_selector ".sort_link.asc", text: "VERSEMENT VOLONTAIRE ▲"
  end

  test "Should sort asc Abondement net when click Abondement net" do
    visit goxygene.managements_pee_histories_path
    click_on "Abondement Net"
    assert_selector ".sort_link.asc", text: "ABONDEMENT NET ▲"
  end

  test "Should sort asc CSG sur Abondement when click CSG sur Abondement" do
    visit goxygene.managements_pee_histories_path
    click_on "CSG sur Abondement"
    assert_selector ".sort_link.asc", text: "CSG SUR ABONDEMENT ▲"
  end

  test "Should sort asc Total Abondement when click Total Abondement" do
    visit goxygene.managements_pee_histories_path
    click_on "Total Abondement"
    assert_selector ".sort_link.asc", text: "TOTAL ABONDEMENT ▲"
  end

  test "Should sort asc Investissement when click Investissement" do
    visit goxygene.managements_pee_histories_path
    click_on "Investissement"
    assert_selector ".sort_link.asc", text: "INVESTISSEMENT ▲"
  end

  test "Should sort asc Date de versement when click Date de versement" do
    visit goxygene.managements_pee_histories_path
    click_on "Date de versement"
    assert_selector ".sort_link.asc", text: "DATE DE VERSEMENT ▲"
  end

  test "Should sort asc Forfait social when click Date de Forfait social" do
    visit goxygene.managements_pee_histories_path
    click_on "Forfait social"
    assert_selector ".sort_link.asc", text: "FORFAIT SOCIAL ▲"
  end

  test "Should sort asc Chrono when click Chrono" do
    visit goxygene.managements_pee_histories_path
    click_on "Chrono"
    assert_selector ".sort_link.asc", text: "CHRONO ▲"
  end

  test "Should sort asc Date de comptabilisation when click Date de comptabilisation" do
    visit goxygene.managements_pee_histories_path
    click_on "Date de comptabilisation"
    assert_selector ".sort_link.asc", text: "DATE DE COMPTABILISATION ▲"
  end

  test "Should sort asc Créé le when click Date de Créé le" do
    visit goxygene.managements_pee_histories_path
    click_on "Créé le"
    assert_selector ".sort_link.asc", text: "CRÉÉ LE ▲"
  end

  test "Should sort asc Créé par when click Date de Créé par" do
    visit goxygene.managements_pee_histories_path
    click_on "Créé par"
    assert_selector ".sort_link.asc", text: "CRÉÉ PAR ▲"
  end

  test "Should go to consultant timeline when click consultant name" do
    visit goxygene.managements_pee_histories_path
    find('tr:first-child a[href*="/consultants/"]').click
    assert_selector "li.active", text: "TIMELINE"
  end

  test "Should have results when filter with date of versement" do
    visit goxygene.managements_pee_histories_path
    click_on "Filtres"
    fill_in "q[deposit_date_gteq]", with: "01/01/2020"
    click_on "Filtres"
    fill_in "q[deposit_date_lteq]", with: "31/12/2020"
    assert_selector "div#pee-lists"
  end

  test "click excel icon" do
    visit goxygene.managements_pee_histories_path
    page.execute_script('$.find(".text-green")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH+"/managements_pee_histories.xlsx"
    assert File.exist?(full_path)
  end

  # test "Should select all checkbox and generate all remise" do
  #   visit goxygene.managements_pee_histories_path
  #   find("#check-all.no-edit", visible: false).set(true)
  #   click_on 'Générer remise PEE'
  #   sleep 1
  #   find("#modal input.btn.btn-orange").click
  #   sleep 5
  #   assert_selector ".inscription-menus li.active a", text: "Historique"
  # end
end
