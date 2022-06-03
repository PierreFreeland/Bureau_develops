require "application_system_test_case"
require "goxygene_set_up"

class ManagementBillingDetailsTest < GoxygeneSetUp
  test "Should redirect to consultant billings from consultant link" do
    visit goxygene.managements_billing_details_path(Goxygene::CustomerBill.last)
    execute_script("document.querySelector('#consultant-link').click()")
    assert_selector 'h4', text: 'FACTURATION'
  end

  test "Should redirect to establishment billings from establishment link" do
    visit goxygene.managements_billing_details_path(Goxygene::CustomerBill.last)
    execute_script("document.querySelector('#client-link').click()")
    assert_selector 'h4', text: 'FACTURES'
  end

  test "Should redirect to establishment contact from establishment contact link" do
    visit goxygene.managements_billing_details_path(Goxygene::CustomerBill.last)
    execute_script("document.querySelector('#client-contact-link').click()")
    assert_selector 'a', text: 'Données du Contact'
  end

  test "Should redirect to business contract from business contract link" do
    visit goxygene.managements_billing_details_path(Goxygene::CustomerBill.last)
    execute_script("document.querySelector('#business-contract-link').click()")
    assert_selector 'h4', text: 'CONTRAT DE PRESTATION'
  end

  test "Should open modal if click Imprimer" do
    visit goxygene.managements_billing_details_path(Goxygene::CustomerBill.last)
    click_on "Imprimer"
    assert_selector "h4", text: "Imprimer la facture"
  end

  test "Should redirect to office customer bill from demande consultant link" do
    visit goxygene.managements_billing_details_path(Goxygene::CustomerBill.last)
    click_on "Demande consultant"
    assert_selector "h4", text: "DÉTAILS"
  end
end