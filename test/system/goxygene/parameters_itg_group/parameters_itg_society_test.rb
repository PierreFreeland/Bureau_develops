require "application_system_test_case"
require "goxygene_set_up"

class ParametersItgSocietyTest < GoxygeneSetUp

  setup do
    visit goxygene.itg_society_index_path
  end

  test "Should open create itg company modal" do
    click_on "Créer une société #{Goxygene::Parameter.value_for_group}"
    assert_selector "h4", "Créer une société #{Goxygene::Parameter.value_for_group}"
  end

  test "Should create new itg company" do
    click_on "Créer une société #{Goxygene::Parameter.value_for_group}"
    fill_in "itg_company_corporate_name", with: "Test"
    within "#itg_company_legal_form_id" do
      find("option[value='1']").click
    end
    fill_in "itg_company_siren", with: "561927658"
    fill_in "itg_company_account_tier", with: "030"
    fill_in "itg_company_payroll_code", with: "TEST"

    # fill employee select2
    all('.select2')[2].click
    find(:css, "input[class$='select2-search__field']").set("#{Goxygene::Parameter.value_for_group}")
    sleep(1)
    all('.select2-results__option')[0].click

    #fill employee select2
    all('.select2')[3].click
    find(:css, "input[class$='select2-search__field']").set("LEVY-WAITZ")
    sleep(1)
    all('.select2-results__option')[0].click

    click_on "Enregistrer"
    assert_selector "td", "Test"
  end

  test "Should have siret format error message when create itg company" do
    click_on "Créer une société #{Goxygene::Parameter.value_for_group}"
    fill_in "itg_company_corporate_name", with: "Test"
    within "#itg_company_legal_form_id" do
      find("option[value='1']").click
    end
    fill_in "itg_company_siren", with: "0000000"
    fill_in "itg_company_account_tier", with: "030"
    fill_in "itg_company_payroll_code", with: "TEST"

    # fill employee select2
    all('.select2')[2].click
    find(:css, "input[class$='select2-search__field']").set("#{Goxygene::Parameter.value_for_group}")
    sleep(1)
    all('.select2-results__option')[0].click

    #fill employee select2
    all('.select2')[3].click
    find(:css, "input[class$='select2-search__field']").set("LEVY-WAITZ")
    sleep(1)
    all('.select2-results__option')[0].click

    click_on "Enregistrer"
    assert_selector "td", "Test"
  end

  test "Should open edit itg company modal" do
    all('.fa-pencil').first.click()
    assert_selector "h4", "Modifier Société #{Goxygene::Parameter.value_for_group}"
  end

  test "Should update itg company data" do
    all('.fa-pencil').first.click()
    fill_in "itg_company_corporate_name", with: "EDITED Institut du Temps Géré"
    fill_in "itg_company_siren", with: "561927658"
    click_on "Enregistrer"
    assert_selector "td", "EDITED Institut du Temps Géré"
  end
end
