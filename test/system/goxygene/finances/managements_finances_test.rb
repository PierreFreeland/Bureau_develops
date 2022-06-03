require "application_system_test_case"
require "goxygene_set_up"

class ManagementsFinancesTest < GoxygeneSetUp

  test "Should go to managements finances billing page when click Facturation annuelle" do
    visit goxygene.managements_finance_billings_path
    within(:css, ".inscription-menus") do
      click_link "Facturation annuelle"
      assert_selector ".inscription-menus li.active a", "Facturation annuelle"
    end
  end

  test "Should go to managements finances turnovers page when click CA / Heures / Brut sur l'année" do
    visit goxygene.managements_finance_billings_path
    click_on "CA / Heures / Brut sur l'année"
    assert_selector ".inscription-menus li.active a", "CA / Heures / Brut sur l'année"
  end

  test "Should go to managements finances turnovers page when click Impression des factures de l'année" do
    visit goxygene.managements_finance_billings_path
    click_on "Impression des factures de l'année"
    assert_selector ".inscription-menus li.active a", "Impression des factures de l'année"
  end
end
