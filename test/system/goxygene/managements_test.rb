require "application_system_test_case"
require "goxygene_set_up"
require 'api_accountancy'

class ManagementsTest < GoxygeneSetUp

  test "Should redirect to managements menu" do
    visit goxygene.managements_path
    assert_selector "a", text: "Gestion"
  end

  test "Should redirect to invoice page from management menu" do
    visit goxygene.managements_path
    click_on "FACTURATION"
    assert_selector "h4", text: "FACTURES"
  end

  test "Should redirect to consultant payment page from management menu" do
    visit goxygene.managements_path
    click_on "PAIEMENTS CONSULTANTS"
    assert_selector "h4", text: "VIREMENTS À TRAITER"
  end

  test "Should redirect to client transfer page from management menu" do
    visit goxygene.managements_path
    click_on "ENCAISSEMENTS"
    assert_selector "h4", text: "VIREMENTS CLIENT"
  end

  test "Should redirect to wage page from management menu" do
    visit goxygene.managements_path
    click_on "SALAIRES"
    assert_selector "h4", text: "SALAIRES"
  end

  test "Should redirect to da page from management menu" do
    visit goxygene.managements_path
    click_on "DA & FRAIS"
    assert_selector "h4", text: "DÉCLARATION D'ACTIVITÉ"
  end

  test "Should redirect to advances page from management menu" do
    visit goxygene.managements_path
    click_on "AVANCES"
    assert_selector "h4", text: "AVANCES"
  end

  test "Should redirect to pees info page from management menu" do
    visit goxygene.managements_path
    click_on "PEE"
    assert_selector "h4", text: "PLAN EPARGNE ENTREPRISE (PEE)"
  end

  test "Should redirect to cesu info page from management menu" do
    visit goxygene.managements_path
    click_on "CESU"
    assert_selector "h4", text: "CESU"
  end

  test "Should redirect to dess page from management menu" do
    visit goxygene.managements_path
    click_on "DES"
    assert_selector "h4", text: "DÉCLARATION DES"
  end

  test "Should redirect to financial billings page from management menu" do
    visit goxygene.managements_path
    click_on "FINANCE"
    assert_selector "h4", text: "FACTURATION ANNUELLE"
  end
end