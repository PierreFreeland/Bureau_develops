require "application_system_test_case"
require "goxygene_set_up"

class ManagementsPrintInvoicesTest < GoxygeneSetUp

  test "Should have valid actions when company has customer bill " do
    visit goxygene.print_invoices_path
    select "I.T.G - CONSEIL", from: "itg_company_id"
    click_on "Rechercher"
    assert_selector "h4", "Impression des factures"
    assert_selector ".btn-default", "Annuler"
    assert_selector ".btn-orange", "Imprimer"
  end

  test "Should have valid actions when company no customer bill " do
    visit goxygene.print_invoices_path
    select "Institut du Temps Géré", from: "itg_company_id"
    click_on "Rechercher"
    assert_selector "h4", text: "Impression des factures"
    assert_selector ".btn-default", "Annuler"
  end

end
