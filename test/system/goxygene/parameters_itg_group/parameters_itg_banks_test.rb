require "application_system_test_case"
require "goxygene_set_up"

class ParametersItgBanksTest < GoxygeneSetUp

  setup do
    visit goxygene.itg_banks_path
  end

  test "Shoud redirect to itg bank detail page" do
    page.all("section").first.click()
    assert_selector "h4", "BANQUES ET AGENCES"
  end

  test "Shoud update itg bank detail" do
    page.all("section").first.click()
    fill_in "itg_bank_company_attributes_corporate_name", with: "EDITED HSBC"
    click_on "Enregister"
    page.driver.browser.navigate.refresh
    assert_selector "input", "EDITED HSBC"
  end

  test "Should redirect to itg bank agency detail from itg bank" do
    page.all("section").first.click()
    page.all("tbody tr").first.click()
    assert_selector "h4", "DONNÉES DE L’AGENCE BANCAIRE"
  end

  test "Should open create itg bank modal" do
    click_on "Ajout d’une banque #{Goxygene::Parameter.value_for_group}"
    assert_selector "h4", "AJOUT D’UNE BANQUE #{Goxygene::Parameter.value_for_group}"
  end

  test "Should create new itg bank" do
    click_on "Ajout d’une banque #{Goxygene::Parameter.value_for_group}"
    fill_in "itg_bank_company_attributes_corporate_name", with: "TEST bank"
    fill_in "itg_bank_company_attributes_acronym", with: "TEST"
    fill_in "itg_bank_bank_code", with: "test"
    click_on "Enregistrer"
    assert_selector("div.text-2", "TEST bank")
  end

end
