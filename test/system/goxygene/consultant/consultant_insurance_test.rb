require "application_system_test_case"
require "goxygene_set_up"

class ConsultantInsuranceTest < GoxygeneSetUp

  setup do
    visit goxygene.consultant_insurance_path(Goxygene::Consultant.find(8786))
    assert_selector "li.active", text: "CONSULTANT"
  end

  test 'Should show a information' do
    assert_selector "h4", text: "ASSURANCE"
    assert_selector "li.active", text: "Assurance"

    assert_selector "h4", text: "PÔLE EMPLOI"
    assert_selector "h4", text: "INFORMATION RETRAITE"
    assert_selector "h4", text: "ASSURANCE RAPATRIEMENT"
    assert_selector "h4", text: "MUTUELLE"
  end

  test 'Should update the pole' do
    select "GENERALI" , from: "consultant_pole_contracts_attributes_0_insurance_company_id"
    fill_in "consultant[pole_contracts_attributes][0][valid_from]", with: Date.today.strftime("%d/%m/%Y")
    fill_in "consultant[pole_contracts_attributes][0][valid_until]", with: (Date.today + 30).strftime("%d/%m/%Y")
    click_on "Enregistrer"
    assert_selector "#consultant_pole_contracts_attributes_0_insurance_company_id option[selected='selected']", text: "GENERALI"
    assert_input '#consultant_pole_contracts_attributes_0_valid_from', Date.today.strftime("%d/%m/%Y")
    assert_input '#consultant_pole_contracts_attributes_0_valid_until', (Date.today + 30).strftime("%d/%m/%Y")
  end

  test 'Should update the information' do
    Goxygene::Consultant.find(8786).itg_company.itg_insurance_contracts.retraite.first.update valid_from: (Date.today - 15), valid_until: (Date.today + 15)

    select "GENERALI" , from: "consultant_information_contracts_attributes_0_insurance_company_id"
    select "382408", from: "consultant_information_contracts_attributes_0_itg_insurance_contract_id"
    click_on "Enregistrer"
    assert_selector "#consultant_information_contracts_attributes_0_insurance_company_id option[selected='selected']", text: "GENERALI"
    assert_selector "#consultant_information_contracts_attributes_0_itg_insurance_contract_id option[selected]", text: '382408'
  end

  test 'Should update the insurance' do
    Goxygene::Consultant.find(8786).itg_company.itg_insurance_contracts.rapatriement.first.update valid_from: (Date.today - 15), valid_until: (Date.today + 15)

    find('a[data-target="#repatriation-contract-items"] i').click
    find('#repatriation-contract-items .insurance-company-selector').find(:option, text: "ATRADIUS").select_option
    find('#repatriation-contract-items .itg-insurance-contract-selector').find(:option, text: "382407").select_option
    click_on "Enregistrer"
    assert_selector "td", text: "ATRADIUS"
    assert_selector "td", text: '382407'
  end

  test 'Should update the mutual' do
    Goxygene::Consultant.find(8786).itg_company.itg_insurance_contracts.mutuelle.first.update valid_from: (Date.today - 15), valid_until: (Date.today + 15)

    find('a[data-target="#mutual-contract-items"] i').click
    find('#mutual-contract-items .insurance-company-selector').find(:option, text: "GENERALI").select_option
    find('#mutual-contract-items .itg-insurance-contract-selector').find(:option, text: "382411").select_option
    click_on "Enregistrer"
    assert_selector "td", text: "GENERALI"
    assert_selector "td", text: '382411'
  end
end
