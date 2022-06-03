require "application_system_test_case"
require "goxygene_set_up"

class ParametersInsuranceContractsTest < GoxygeneSetUp

  setup do
    visit goxygene.insurance_contracts_path
  end

  test "Should open create insurance contract modal" do
    click_on "Créer un contrat d’assurance"
    assert_selector "h4", "Créer un contrat d’assurance"
  end

  test "Should create new itg insurance contract" do
    before = page.all('tr').count
    click_on "Créer un contrat d’assurance"
    within "#itg_insurance_contract_itg_insurance_contracts_itg_companies_attributes_0_itg_company_id" do
      find("option[value='1']").click
    end
    within "#itg_insurance_contract_insurance_type_id" do
      find("option[value='3']").click
    end
    within "#itg_insurance_contract_insurance_company_id" do
      find("option[data-id='3']").click
    end
    fill_in "itg_insurance_contract_reference_number", with: "AL 254 757"
    execute_script("$('#itg_insurance_contract_valid_from').val('#{Date.today.strftime("%d/%m/%Y")}')")
    execute_script("$('#itg_insurance_contract_valid_until').val('#{(Date.today + 30).strftime("%d/%m/%Y")}')")
    click_on "Enregistrer"
    sleep 1
    assert_equal(before + 1, page.all('tr').count)
  end

  test "Should have end date less than begin date error message" do
    click_on "Créer un contrat d’assurance"
    within "#itg_insurance_contract_itg_insurance_contracts_itg_companies_attributes_0_itg_company_id" do
      find("option[value='1']").click
    end
    within "#itg_insurance_contract_insurance_type_id" do
      find("option[value='3']").click
    end
    within "#itg_insurance_contract_insurance_company_id" do
      find("option[data-id='3']").click
    end
    fill_in "itg_insurance_contract_reference_number", with: "AL 254 757"
    execute_script("$('#itg_insurance_contract_valid_from').val('#{Date.today.strftime("%d/%m/%Y")}')")
    execute_script("$('#itg_insurance_contract_valid_until').val('#{(Date.today - 1).strftime("%d/%m/%Y")}')")
    click_on "Enregistrer"
    assert_selector "li", "Valide jusqu'à doit être supérieur ou égal Valide à partir de", wait: 2
  end

  test "Should have unavailable itg company error message in case valid from and valid until inside range" do
    click_on "Créer un contrat d’assurance"
    within "#itg_insurance_contract_itg_insurance_contracts_itg_companies_attributes_0_itg_company_id" do
      find("option[value='9']").click
    end
    within "#itg_insurance_contract_insurance_type_id" do
      find("option[value='3']").click
    end
    within "#itg_insurance_contract_insurance_company_id" do
      find("option[data-id='3']").click
    end
    fill_in "itg_insurance_contract_reference_number", with: "AL 254 757"
    execute_script("$('#itg_insurance_contract_valid_from').val('01/07/2019')")
    execute_script("$('#itg_insurance_contract_valid_until').val('30/10/2019')")
    click_on "Enregistrer"
    assert_selector "li", "I.T.G - CONSEIL. Il existe déjà un contrat d'assurance valide sur cette période pour cette société, vous ne pouvez pas créer de nouveau contrat.", wait: 2
  end

  test "Should have unavailable itg company error message in case date valid from and valid until outside range" do
    click_on "Créer un contrat d’assurance"
    within "#itg_insurance_contract_itg_insurance_contracts_itg_companies_attributes_0_itg_company_id" do
      find("option[value='9']").click
    end
    within "#itg_insurance_contract_insurance_type_id" do
      find("option[value='3']").click
    end
    within "#itg_insurance_contract_insurance_company_id" do
      find("option[data-id='3']").click
    end
    fill_in "itg_insurance_contract_reference_number", with: "AL 254 757"
    execute_script("$('#itg_insurance_contract_valid_from').val('31/12/2014')")
    execute_script("$('#itg_insurance_contract_valid_until').val('01/01/2020')")
    click_on "Enregistrer"
    assert_selector "li", "I.T.G - CONSEIL. Il existe déjà un contrat d'assurance valide sur cette période pour cette société, vous ne pouvez pas créer de nouveau contrat.", wait: 2
  end

  test "Should have unavailable itg company error message in case date valid from inside range" do
    click_on "Créer un contrat d’assurance"
    within "#itg_insurance_contract_itg_insurance_contracts_itg_companies_attributes_0_itg_company_id" do
      find("option[value='9']").click
    end
    within "#itg_insurance_contract_insurance_type_id" do
      find("option[value='3']").click
    end
    within "#itg_insurance_contract_insurance_company_id" do
      find("option[data-id='3']").click
    end
    fill_in "itg_insurance_contract_reference_number", with: "AL 254 757"
    execute_script("$('#itg_insurance_contract_valid_from').val('31/12/2015')")
    execute_script("$('#itg_insurance_contract_valid_until').val('01/01/2020')")
    click_on "Enregistrer"
    assert_selector "li", "I.T.G - CONSEIL. Il existe déjà un contrat d'assurance valide sur cette période pour cette société, vous ne pouvez pas créer de nouveau contrat.", wait: 2
  end

  test "Should have unavailable itg company error message in case date valid until inside range" do
    click_on "Créer un contrat d’assurance"
    within "#itg_insurance_contract_itg_insurance_contracts_itg_companies_attributes_0_itg_company_id" do
      find("option[value='9']").click
    end
    within "#itg_insurance_contract_insurance_type_id" do
      find("option[value='3']").click
    end
    within "#itg_insurance_contract_insurance_company_id" do
      find("option[data-id='3']").click
    end
    fill_in "itg_insurance_contract_reference_number", with: "AL 254 757"
    execute_script("$('#itg_insurance_contract_valid_from').val('31/12/2014')")
    execute_script("$('#itg_insurance_contract_valid_until').val('01/01/2019')")
    click_on "Enregistrer"
    assert_selector "li", "I.T.G - CONSEIL. Il existe déjà un contrat d'assurance valide sur cette période pour cette société, vous ne pouvez pas créer de nouveau contrat.", wait: 2
  end

  test "Should update non-association insurance contract data" do
    all('.fa-pencil').first.click()
    fill_in "itg_insurance_contract_label", with: "Test update"
    click_on "Enregistrer"
    assert_selector "td", "Test update"
  end

  test "Should update association insurance contract data" do
    all('.fa-pencil').first.click()
    within "#itg_insurance_contract_insurance_type_id" do
      find("option[value='2']").click
    end
    within "#itg_insurance_contract_insurance_company_id" do
      find("option[data-id='2']").click
    end
    execute_script("$('#itg_insurance_contract_valid_from').val('01/10/2020')")
    execute_script("$('#itg_insurance_contract_valid_until').val('30/10/2020')")
    click_on "Enregistrer"
    assert_selector "td", "Retraite"
  end

  test "Should have validate unavailable itg company when update" do
    all('.fa-pencil').first.click()
    within "#itg_insurance_contract_insurance_type_id" do
      find("option[value='5']").click
    end
    within "#itg_insurance_contract_insurance_company_id" do
      find("option[data-id='5']").click
    end
    click_on "Enregistrer"
    assert_selector "li", "I.T.G - CONSEIL. Il existe déjà un contrat d'assurance valide sur cette période pour cette société, vous ne pouvez pas créer de nouveau contrat.", wait: 2
  end
end
