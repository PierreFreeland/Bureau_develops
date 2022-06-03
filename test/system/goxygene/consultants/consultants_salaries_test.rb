require "application_system_test_case"
require "goxygene_set_up"

class ConsultantsSalariesTest < GoxygeneSetUp

  setup do
    visit goxygene.consultants_salaries_path
    assert_selector "h4", text: "SALAIRES EN ATTENTE"
  end

  test "Should show the table" do
    assert_selector "th", text: "ETAT / STATUT"
    assert_selector "th", text: "CODE PAIE"
    assert_selector "th", text: "STATUT"
    assert_selector "th", text: "CONSULTANT"
    assert_selector "th", text: "ANNÉE"
    assert_selector "th", text: "MOIS"
    assert_selector "th", text: "DATE DE DÉBUT"
    assert_selector "th", text: "DATE DE FIN"
    assert_selector "th", text: "HEURES"
    assert_selector "th", text: "CONGÉS"
    assert_selector "th", text: "MALADIE"
    assert_selector "th", text: "BASE H."
    assert_selector "th", text: "CONVENTIONNEL"
    assert_selector "th", text: "COMPLÉMENTAIRE"
    assert_selector "th", text: "BRUT"
    assert_selector "th", text: "NET"
    assert_selector "th", text: "PAS"
    assert_selector "th", text: "NET APRÈS PAS"
    assert_selector "th", text: "INDEMNITÉS"
    assert_selector "th", text: "OPPOSITIONS"
    assert_selector "th", text: "COÛT"
    assert_selector "th", text: "DATE"
    assert_selector "th", text: "CHRONO"
    assert_selector "th", text: "CHRONO ANNULATION"
    assert_selector "th", text: "DATE RÈGLEMENT"
    assert_selector "th", text: "COMMENTAIRES"
  end

  test "Should go to consultant when click a one of list" do
    page.all('td a[href*="consultants"]').first.click
    assert_selector "h4", text: "TIMELINE"
  end

  test "Should filter the list" do
    find(".click-to-hide").click
    click_on "Filtres"
    fill_in "q[month_and_year_gteq]", with: "01/2020"
    fill_in "q[month_and_year_lteq]", with: "02/2020"
    click_on "Rechercher"

    assert page.all('table.list-table tr').count > 1
  end

  test "Should go back to consultants page" do
    click_on "Retour"
    assert_selector "h4", text: "LES CHIFFRES #{Goxygene::Parameter.value_for_group}"
  end
end
