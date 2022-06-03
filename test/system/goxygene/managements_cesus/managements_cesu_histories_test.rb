require "application_system_test_case"
require "goxygene_set_up"

class ManagementsCesuHistoriesTest < GoxygeneSetUp

  test "Should show filter cesu when click Filtres" do
    visit goxygene.managements_cesu_histories_path
    click_on "Filtres"
    assert_selector "#filter-search.panel.collapse.in"
  end

  test "Should sort asc Consultant when click Consultant" do
    ActiveRecord::Migration.enable_extension "unaccent"
    visit goxygene.managements_cesu_histories_path
    find('.sort_link[href*="consultant_individual_full_name"]').click
    assert_selector ".sort_link.asc", text: "CONSULTANT ▲"
  end

  test "Should sort asc SOCIÉTÉ ITG when click SOCIÉTÉ ITG" do
    visit goxygene.managements_cesu_histories_path
    click_on "SOCIÉTÉ #{Goxygene::Parameter.value_for_group}"
    assert_selector ".sort_link.asc", text: "SOCIÉTÉ #{Goxygene::Parameter.value_for_group} ▲"
  end

  test "Should sort asc ECESU when click ECESU" do
    visit goxygene.managements_cesu_histories_path
    click_on "eCESU"
    assert_selector ".sort_link.asc", text: "ECESU ▲"
  end

  test "Should sort asc NOMBRE DE CHÈQUES when click NOMBRE DE CHÈQUES" do
    visit goxygene.managements_cesu_histories_path
    click_on "NOMBRE DE CHÈQUES"
    assert_selector ".sort_link.asc", text: "NOMBRE DE CHÈQUES ▲"
  end

  test "Should sort asc MONTANT when click MONTANT" do
    visit goxygene.managements_cesu_histories_path
    click_on "MONTANT"
    assert_selector ".sort_link.asc", text: "MONTANT ▲"
  end

  test "Should sort asc FRAIS DE FABRICATION when click FRAIS DE FABRICATION" do
    visit goxygene.managements_cesus_path
    click_on "FRAIS DE FABRICATION"
    assert_selector ".sort_link.asc", text: "FRAIS DE FABRICATION ▲"
  end

  test "Should sort asc CHRONO when click CHRONO" do
    visit goxygene.managements_cesu_histories_path
    click_on "CHRONO"
    assert_selector ".sort_link.asc", text: "CHRONO ▲"
  end

  test "Should sort asc VALIDÉ LE when click Date de VALIDÉ LE" do
    visit goxygene.managements_cesu_histories_path
    click_on "VALIDÉ LE"
    assert_selector ".sort_link.asc", text: "VALIDÉ LE ▲"
  end

  test "Should sort asc VALIDÉ PAR when click Date de VALIDÉ PAR" do
    ActiveRecord::Migration.enable_extension "unaccent"
    visit goxygene.managements_cesu_histories_path
    click_on "VALIDÉ PAR"
    assert_selector ".sort_link.asc", text: "VALIDÉ PAR ▲"
  end

  test "Should go to consultant timeline when click consultant name" do
    visit goxygene.managements_cesu_histories_path
    find('tr:first-child a[href*="/consultants/"]').click
    assert_selector "li.active", text: "TIMELINE"
  end

  test "Should have results when filter with date of versement" do
    visit goxygene.managements_cesu_histories_path
    click_on "Filtres"
    fill_in "q[created_at_gteq]", with: "01/01/2020"
    click_on "Filtres"
    fill_in "q[created_at_lteq]", with: "31/12/2020"
    assert_selector "div#cesu-lists"
  end

  test "click excel icon" do
    visit goxygene.managements_cesu_histories_path
    page.execute_script('$.find(".text-green")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH+"/managements_cesu_histories.xlsx"
    assert File.exist?(full_path)
  end

  # test "Should select all checkbox and generate all remise" do
  #   visit goxygene.managements_cesu_histories_path
  #   find("#check-all.no-edit", visible: false).set(true)
  #   click_on 'Générer remise CESU'
  #   sleep 1
  #   find("#modal input.btn.btn-orange").click
  #   sleep 5
  #   assert_selector ".inscription-menus li.active a", text: "Historique"
  # end
end
