require "application_system_test_case"
require "goxygene_set_up"

class ParametersItgBankAgenciesTest < GoxygeneSetUp

  setup do
    visit goxygene.itg_bank_agencies_path
  end

  test "Should redirect to itg bank agency detail page" do
    page.all("tbody tr").first.click()
    assert_selector "h4", "DONNÉES DE L’AGENCE BANCAIRE"
  end

  test "Should update itg bank agency detail" do
    page.all("tbody tr").first.click()
    fill_in "itg_bank_agency_establishment_attributes_company_attributes_corporate_name", with: "EDITED ITC-RH"
    click_on "Enregistrer"
    page.driver.browser.navigate.refresh
    assert_selector "input", "EDITED ITC-RH"
  end

  test "Should update itg bank agency's contact data" do
    page.all("tbody tr").first.click()
    fill_in "itg_bank_agency_establishment_attributes_contact_datum_attributes_address_1", with: "Address 1"
    click_on "Enregistrer"
    page.driver.browser.navigate.refresh
    assert_selector "input", "Address 1"
  end

  test "Should update itg bank agency's establishment contact data" do
    page.all("tbody tr").first.click()
    execute_script("$('.fa-plus').first().click()")
    execute_script("$('#itg-bank-agency-contact-items .form-control').eq(0).val('Test-lastname')")
    execute_script("$('#itg-bank-agency-contact-items .form-control').eq(1).val('Test-name')")
    execute_script("$('#itg-bank-agency-contact-items .form-control').eq(5).val(1)")
    execute_script("$('#itg-bank-agency-contact-items .form-control').eq(6).val(1)")
    execute_script("$('#itg-bank-agency-contact-items .form-control').eq(7).val(1)")
    sleep 1
    click_on "Enregistrer"
    assert_selector("div.fields", "Test-name")
  end

  test "Should update itg bank agency's itg bank account data" do
    page.all("tbody tr").first.click()
    execute_script("$('.fa-plus').last().click()")
    execute_script("$('#itg-bank-account-items .form-control').eq(1).val(1)")
    execute_script("$('#itg-bank-account-items .form-control').eq(2).val('FR7630066109470002017250105')")
    execute_script("$('#itg-bank-account-items .form-control').eq(3).val('TEST')")
    sleep 1
    click_on "Enregistrer"
    assert_selector("div.fields", "TEST")
  end

  test "Should open create itg bank agency modal" do
    click_on "Créer une agence bancaire"
    assert_selector "h4", "Créer une agence bancaire"
  end

  test "Should create new itg bank agency" do
    click_on "Créer une agence bancaire"
    within "#itg_bank_agency_establishment_attributes_company_id" do
      find("option[value='68005']").click
    end
    fill_in "itg_bank_agency_sort_code", with: "00001"
    fill_in "itg_bank_agency_domiciliation", with: "FR7630066109470002017250105"
    fill_in "itg_bank_agency_establishment_attributes_name", with: "TEST"
    fill_in "itg_bank_agency_swift", with: "TTEESSTT"
    click_on "Enregistrer"
    assert_selector "td", "TEST"
  end
end
