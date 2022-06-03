require "application_system_test_case"
require "goxygene_set_up"

class ManagementClientTransferSubNavTest < GoxygeneSetUp
  test "Should redirect to client transfer" do
    visit goxygene.managements_client_transfers_path
    within '.inscription-menus' do
      first(:link, "Virements client")
    end
    assert_selector 'h4', 'VIREMENTS CLIENT'
  end

  test "Should redirect to client cheques" do
    visit goxygene.managements_client_transfers_path
    within '.inscription-menus' do
      first(:link, "Chèques client")
    end
    assert_selector 'h4', 'CHÈQUES CLIENT'
  end

  test "Should redirect to bank slips" do
    visit goxygene.managements_client_transfers_path
    within '.inscription-menus' do
      first(:link, "Bordereaux de remise en banque")
    end
    assert_selector 'h4', 'BORDEREAUX DE REMISE EN BANQUE'
  end

  test "Should redirect to history" do
    visit goxygene.managements_client_transfers_path
    within '.inscription-menus' do
      first(:link, "Règlement / Historique")
    end
    assert_selector 'h4', 'RÈGLEMENT / HISTORIQUE'
  end
end