require "application_system_test_case"
require "goxygene_set_up"

class ManagementsConsultantPaymentsSubTabTest < GoxygeneSetUp

  test "Should redirect to management consultant transfers" do
    visit goxygene.managements_consultant_transfers_path
    assert_selector "h4", "VIREMENTS À TRAITER"
  end

  test "Should redirect to management consultant cheques" do
    visit goxygene.managements_consultant_transfers_path
    within ".inscription-menus" do
      all('li')[1].click
    end
    assert_selector "h4", "CHÈQUES À TRAITER"
  end

  test "Should redirect to management transfer slip histories" do
    visit goxygene.managements_consultant_transfers_path
    within ".inscription-menus" do
      all('li')[2].click
    end
    assert_selector "h4", "HISTORIQUE DES BORDEREAUX DE VIREMENTS"
  end

  test "Should redirect to management bank slip histories" do
    visit goxygene.managements_consultant_transfers_path
    within ".inscription-menus" do
      all('li')[3].click
    end
    assert_selector "h4", "HISTORIQUE DES BORDEREAUX DE CHÈQUES"
  end

  test "Should redirect to transfer slip histories detail" do
    visit goxygene.managements_transfer_slip_histories_path
    page.all('tr')[1].click
    assert_selector "h4", text: "BORDEREAUX DE VIREMENTS"
  end

  test "Should redirect to bank slip histories detail" do
    visit goxygene.managements_bank_slip_histories_path
    page.all('tr')[1].click
    assert_selector "h4", text: "HISTORIQUE DES BORDEREAUX DE CHÈQUES"
  end
end
