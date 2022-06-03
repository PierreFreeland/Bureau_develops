require "application_system_test_case"
require "goxygene_set_up"

class ConsultantsTabTest < GoxygeneSetUp

  setup do
    visit goxygene.consultants_path
  end

  test "Should redirect to consultant tab" do
    assert_selector "h4", "LES CHIFFRES #{Goxygene::Parameter.value_for_group}"
  end

  test "Should redirect to Demandes de DA page" do
    all('.fa-arrow-right')[0].click
    assert_selector "h4", "DEMANDES DE DA"
  end

  test "Should redirect to Salaires en attente page" do
    all('.fa-arrow-right')[1].click
    assert_selector "h4", "SALAIRES EN ATTENTE"
  end

  test "Should redirect to Demandes de factures page" do
    all('.fa-arrow-right')[2].click
    assert_selector "h4", "DEMANDES DE FACTURES"
  end

  test "Should redirect to Demandes de contrats  page" do
    all('.fa-arrow-right')[3].click
    assert_selector "h4", "DEMANDES DE CONTRATS"
  end

  test "Should redirect to Demandes de rappel et alertes page" do
    all('.fa-arrow-right')[4].click
    assert_selector "h4", "DEMANDES DE RAPPEL ET ALERTES"
  end

  test "Should redirect to Demandes de mise à jour page" do
    all('.fa-arrow-right')[5].click
    assert_selector "h4", "DEMANDES DE MISE À JOUR"
  end

  test "Should redirect to consultant lists page" do
    all("a.dashboard-text")[0].click
    assert_selector "h4", "CONSULTANTS"
  end

  test "Should redirect to NOUVEAUX CONSULTANTS page" do
    all("a.dashboard-text")[1].click
    assert_selector "h4", "NOUVEAUX CONSULTANTS"
  end

  test "Should redirect to CA CONSULTANTS page" do
    all("a.dashboard-text")[2].click
    assert_selector "h4", "CA CONSULTANTS"
  end
end

