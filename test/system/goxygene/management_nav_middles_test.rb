require "application_system_test_case"
require "goxygene_set_up"

class ManagementNavMiddlesTest < GoxygeneSetUp

  test "Should redirect to invoice page from nav middle" do
    visit goxygene.managements_billings_path
    click_link "Facturation"
    assert_selector "h4", text: "FACTURES"
  end

  test "Should redirect to consultant payment consultant transfer from nav middle" do
    visit goxygene.managements_billings_path
    click_link "Paiements Consultants"
    assert_selector "h4", text: "VIREMENTS À TRAITER"
  end

  test "Should redirect to client transfer from nav middle" do
    visit goxygene.managements_billings_path
    click_link "Encaissements"
    assert_selector "h4", text: "VIREMENTS CLIENT"
  end

  test "Should redirect wage from nav middle" do
    visit goxygene.managements_billings_path
    click_link "Salaires"
    assert_selector "h4", text: "SALAIRES"
  end

  test "Should redirect to das from nav middle" do
    visit goxygene.managements_billings_path
    click_link "DA & Frais"
    assert_selector "h4", text: "DÉCLARATION D'ACTIVITÉ"
  end

  test "Should redirect to advances from nav middle" do
    visit goxygene.managements_billings_path
    click_link "Avances"
    assert_selector "h4", text: "AVANCES"
  end

  test "Should redirect to pee infos from nav middle" do
    visit goxygene.managements_billings_path
    click_link "PEE"
    assert_selector "h4", text: "PLAN EPARGNE ENTREPRISE (PEE)"
  end

  test "Should redirect to cesu infos from nav middle" do
    visit goxygene.managements_billings_path
    click_link "CESU"
    assert_selector "h4", text: "CESU"
  end

  test "Should redirect to dess histories from nav middle" do
    visit goxygene.managements_billings_path
    click_link "DES"
    assert_selector "h4", text: "HISTORIQUE DES"
  end

  test "Should redirect to financial billings from nav middle" do
    visit goxygene.managements_billings_path
    click_link "FINANCE"
    assert_selector "h4", text: "FACTURATION ANNUELLE"
  end

end