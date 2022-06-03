require "application_system_test_case"
require "goxygene_set_up"

class ManagementWagesTest < GoxygeneSetUp
  test "should have valid actions on to_be_checked" do
    visit goxygene.managements_wages_path
    click_on "Filtres"
    select "A contrôler", from: "q[disbursement_source_status_eq]"
    click_on "Rechercher"
    assert_selector ".btn-orange", text: "Annuler"
    assert_selector ".btn-orange", text: "Bon à payer"
    assert_selector ".btn-orange[value=Enregistrer]"
  end

  test "should have valid actions on query" do
    visit goxygene.managements_wages_path
    click_on "Filtres"
    select "Bon à payer", from: "q[disbursement_source_status_eq]"
    click_on "Rechercher"
    assert_selector ".btn-orange", text: "Annuler"
    assert_selector ".btn-orange", text: "Salaires à contrôler"
    assert_selector ".btn-orange", text: "Passer en ordre"
    assert_selector ".btn-orange[value=Enregistrer]"
  end

  test "should have valid actions on being_processed" do
    visit goxygene.managements_wages_path
    click_on "Filtres"
    select "En traitement paie", from: "q[disbursement_source_status_eq]"
    click_on "Rechercher"
    assert_selector ".btn-orange", text: "Annuler"
    assert_selector ".btn-orange", text: "Récupérer et comptabiliser"
  end

  test "should have valid actions on done" do
    visit goxygene.managements_wages_path
    click_on "Filtres"
    select "Payé", from: "q[disbursement_source_status_eq]"
    click_on "Rechercher"
    assert_selector ".btn-orange", text: "Annuler"
  end

  test "should have valid actions on payroll_error" do
    visit goxygene.managements_wages_path
    click_on "Filtres"
    select "Erreur paie", from: "q[disbursement_source_status_eq]"
    click_on "Rechercher"
    assert_selector ".btn-orange", text: "Annuler"
    assert_selector ".btn-orange", text: "Récupérer et comptabiliser"
    assert_selector ".btn-orange", text: "Forcer le salaire"
  end

  test "should have valid actions on accountancy_error" do
    visit goxygene.managements_wages_path
    click_on "Filtres"
    select "Erreur compta", from: "q[disbursement_source_status_eq]"
    click_on "Rechercher"
    assert_selector ".btn-orange", text: "Annuler"
    assert_selector ".btn-orange", text: "Comptabiliser"
  end

  test "should have valid actions on disbursement_accountancy_error" do
    visit goxygene.managements_wages_path
    click_on "Filtres"
    select "Erreur règlement", from: "q[disbursement_source_status_eq]"
    click_on "Rechercher"
    assert_selector ".btn-orange", text: "Annuler"
    assert_selector ".btn-orange", text: "Comptabiliser"
  end

  test "should have results when filter on done" do
    visit goxygene.managements_wages_path
    click_on "Filtres"
    select "Payé", from: "q[disbursement_source_status_eq]"
    fill_in "q[year_eq]", with: "2019"
    fill_in "q[month_eq]", with: "1"
    click_on "Rechercher"
    assert_selector "td", "Payé"
  end
end
