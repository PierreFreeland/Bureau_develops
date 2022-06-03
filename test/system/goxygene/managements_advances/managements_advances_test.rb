require "application_system_test_case"
require "goxygene_set_up"

class ManagementsAdvancesTest < GoxygeneSetUp

  setup do
    visit goxygene.managements_advances_path
    @before = Goxygene::WageAdvance.where(wage_advance_status: :itg_editing).count
  end

  test "Should redirect to managements advances page" do
    assert_selector "h4", "AVANCES"
  end

  test "Should not open model when click Générer le paiement" do
    accept_confirm "Aucune avance n’est sélectionnée" do
      click_on "Générer le paiement"
    end
  end

  test "Should reject each wage by click on their reject button" do
    accept_alert do
      execute_script("$('a.bg-orange[data-title=Refuser]')[0].click()")
      sleep 2
    end
    page.driver.browser.navigate.refresh
    assert_equal @before - 1, Goxygene::WageAdvance.where(wage_advance_status: :itg_editing).count
  end

  test "Should generate each wage by click on accept button" do
    accept_alert do
      execute_script("$('a.bg-orange[data-title=Accepter]')[0].click()")
      sleep 2
    end
    sleep 3
    accept_alert do
      execute_script("$('a.advance-submit').click()")
      sleep 2
    end
    page.driver.browser.switch_to.alert.accept
    sleep 5
    assert_equal @before - 1, Goxygene::WageAdvance.where(wage_advance_status: :itg_editing).count
  end

  test "Should generate multiple wage by click on Générer le paiement" do
    execute_script("$('input.advance-checkbox[data-id=24384]').click()")
    execute_script("$('input.advance-checkbox[data-id=24385]').click()")
    accept_alert do
      click_on "Générer le paiement"
    end
    sleep 2
    execute_script("$('a.advance-submit').click()")
    sleep 1
    page.driver.browser.switch_to.alert.accept
    sleep 1
    page.driver.browser.switch_to.alert.accept
    sleep 2
    page.driver.browser.navigate.refresh
    sleep 2
    assert_equal @before - 2, Goxygene::WageAdvance.where(wage_advance_status: :itg_editing).count
  end

  test "Should cancel multiple wage by click on Annuler" do
    execute_script("$('input.advance-checkbox[data-id=24384]').click()")
    execute_script("$('input.advance-checkbox[data-id=24385]').click()")
    accept_alert do
      click_on "Annuler"
      sleep 1
    end
    page.driver.browser.navigate.refresh
    sleep 2
    assert_equal @before - 2, Goxygene::WageAdvance.where(wage_advance_status: :itg_editing).count
  end

  test "Should export excel file by click on excel icon" do
    page.execute_script('$.find(".text-green")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH+"/managements_client_cheques.xlsx"
    assert File.exist?(full_path)
  end
end
