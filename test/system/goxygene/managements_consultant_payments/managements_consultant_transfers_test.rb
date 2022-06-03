require "application_system_test_case"
require "goxygene_set_up"

class ManagementsConsultantTransfersTest < GoxygeneSetUp

  test "Should not open brb transfer generate modal" do
    visit goxygene.managements_consultant_transfers_path
    accept_confirm "Sélectionner au moins 1 virement" do
      click_on "Générer les bordereaux de virements"
    end
  end

  test "Should open brb transfer generate modal" do
    visit goxygene.managements_consultant_transfers_path
    # execute_script("$('input.consultant-transfer-checkbox[value=515846]').click()")
    sleep 2
    click_on "Générer les bordereaux de virements"
    assert_selector "h4", "CHOIX DES COMPTES BANCAIRES"
  end

  test "Should generate brb transfer" do
    visit goxygene.managements_consultant_transfers_path
    # execute_script("$('input.consultant-transfer-checkbox[value=515846]').click()")
    sleep 1
    click_on "Générer les bordereaux de virements"
    sleep 1
    execute_script("$('input.generate-submit').click()")
    sleep 7
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert window.size > 1
  end
end
