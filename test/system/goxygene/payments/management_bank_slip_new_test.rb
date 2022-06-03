require "application_system_test_case"
require "goxygene_set_up"

class ManagementBankSlipNewTest < GoxygeneSetUp

  test "Should show filter section" do
    visit goxygene.new_managements_bank_slip_path
    click_on "Filtres"
    assert_selector "label", "Société #{Goxygene::Parameter.value_for_group}"
    assert_selector ".btn-default", "Annuler"
    assert_selector ".btn-orange", "Générer un BRB"
  end

  test "Should not open brb generate modal" do
    visit goxygene.new_managements_bank_slip_path
    accept_confirm "Sélectionner au moins 1 virement" do
      click_on "Générer un BRB"
    end
  end

  test "Should open brb generate modal" do
    visit goxygene.new_managements_bank_slip_path
    find("#check-all.no-edit", visible: false).set(true)
    click_on "Générer un BRB"
    assert_selector "h4", "CHOIX DES COMPTES BANCAIRES"
    assert_selector ".btn-default", "Annuler"
    assert_selector ".btn-orange", "Générer un BRB"
  end

  test "Should generate brb" do
    visit goxygene.new_managements_bank_slip_path
    find("#check-all.no-edit", visible: false).set(true)
    click_on "Générer un BRB"
    execute_script("$('input.generate-submit').click()")
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert window.size >= 1
  end

  test "Should redirect to bank slip list" do
    visit goxygene.new_managements_bank_slip_path
    click_on "Annuler"
    assert_selector 'h4', 'BORDEREAUX DE REMISE EN BANQUE'
  end
end