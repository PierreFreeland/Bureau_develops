require "application_system_test_case"
require "goxygene_set_up"

class ManagementFinancesSubNavTest < GoxygeneSetUp
  test "Should redirect to client transfer" do
    visit goxygene.managements_finance_billings_path
    within '.inscription-menus' do
      first(:link, "Facturation annuelle")
    end
    assert_selector 'h4', 'FACTURATION ANNUELLE'
  end

  test "Should redirect to client cheques" do
    visit goxygene.managements_finance_billings_path
    within '.inscription-menus' do
      first(:link, "CA / Heures / Brut sur l'année")
    end
    assert_selector 'h4', "CA / HEURES / BRUT SUR L'ANNÉE"
  end

  test "Should redirect to bank slips" do
    visit goxygene.managements_finance_billings_path
    within '.inscription-menus' do
      first(:link, "Impression des factures de l'année")
    end
    assert_selector 'h4', "IMPRESSION DES FACTURES DE L'ANNÉE"
  end
end