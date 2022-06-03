require "application_system_test_case"
require "goxygene_set_up"

class ManagementsConsultantChequesTest < GoxygeneSetUp

  test "Should not open brb cheque generate modal" do
    visit goxygene.managements_consultant_cheques_path
    accept_confirm "Sélectionner au moins 1 chèque" do
      click_on "Générer le(s) bordereau(x) de chèques"
    end
  end

  test "Should open brb cheque generate modal" do
    visit goxygene.managements_consultant_cheques_path
    # execute_script("$('input.consultant-cheque-checkbox[value=515622]').click()")
    sleep 2
    click_on "Générer le(s) bordereau(x) de chèques"
    assert_selector "h4", "CHOIX DES COMPTES BANCAIRES"
  end

  test "Should generate brb cheque" do
    visit goxygene.managements_consultant_cheques_path
    # execute_script("$('input.consultant-cheque-checkbox[value=515622]').click()")
    sleep 1
    click_on "Générer le(s) bordereau(x) de chèques"
    sleep 1
    execute_script("$('input.generate-submit').click()")
    sleep 7
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert window.size > 1
  end
end
