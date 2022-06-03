require "application_system_test_case"
require "goxygene_set_up"

class ClientsBusinessContractsTest < GoxygeneSetUp

  setup do
    visit goxygene.client_business_contracts_path(Goxygene::Customer.find(13067))
  end

  test "Should redirect to clients business contracts index page" do
    assert_selector "h4", "CONTRATS COMMERCIAUX"
  end

  test "Should redirect to create clients business contracts ci page" do
    click_on "Créer un contrat commercial"
    click_on "Contrat de prestation"
    assert_selector "h4", "CRÉER UN CONTRAT DE PRESTATION"
  end

  test "Should redirect to create clients business contracts cf page" do
    click_on "Créer un contrat commercial"
    click_on "Convention de formation"
    assert_selector "h4", "CRÉER UNE CONVENTION DE FORMATION"
  end

  test "Should create new business contract type ci" do
    click_on "Créer un contrat commercial"
    click_on "Contrat de prestation"

    sleep 1
    all('.select2')[0].click
    find(:css, "input[class$='select2-search__field']").set("Grant")
    sleep 1
    all('.select2-results__option')[0].click
    sleep 1
    select all("#business_contract_establishment_contact_id option").last.text, from: "business_contract_establishment_contact_id"
    execute_script("$('#business_contract_business_contract_versions_attributes_0_contract_sent_on').val('#{Date.today.strftime("%d/%m/%Y")}')")
    fill_in "business_contract_business_contract_versions_attributes_0_notice_period", with: "10"
    fill_in "business_contract_business_contract_versions_attributes_0_order_amount", with: "100"
    fill_in "business_contract_business_contract_versions_attributes_0_mission_subject", with: "test"
    execute_script("$('#business_contract_business_contract_versions_attributes_0_begining_date').val('#{Date.today.strftime("%d/%m/%Y")}')")
    execute_script("$('#business_contract_business_contract_versions_attributes_0_ending_date').val('#{(Date.today + 15).strftime("%d/%m/%Y")}')")

    click_on "Validation"
    sleep 2

    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert window.size > 1
  end

  test "Should create new business contract type cf" do
    click_on "Créer un contrat commercial"
    click_on "Convention de formation"

    sleep 1
    all('.select2')[0].click
    find(:css, "input[class$='select2-search__field']").set("Grant")
    sleep 1
    all('.select2-results__option')[0].click
    sleep 1
    select all("#business_contract_establishment_contact_id option").last.text, from: "business_contract_establishment_contact_id"
    execute_script("$('#business_contract_business_contract_versions_attributes_0_contract_sent_on').val('#{Date.today.strftime("%d/%m/%Y")}')")
    fill_in "business_contract_business_contract_versions_attributes_0_training_days_before_deadline", with: "10"
    fill_in "business_contract_business_contract_versions_attributes_0_order_amount", with: "1000"
    fill_in "business_contract_business_contract_versions_attributes_0_training_name", with: "test"
    fill_in "business_contract_business_contract_versions_attributes_0_training_purpose", with: "test"
    select "Action d'adaptation au poste de travail", from: "business_contract_business_contract_versions_attributes_0_training_target_id"
    select "110 - Spécialités pluriscientifiques", from: "business_contract_business_contract_versions_attributes_0_training_domain_id"

    execute_script("$('#business_contract_business_contract_versions_attributes_0_begining_date').val('#{Date.today.strftime("%d/%m/%Y")}')")
    execute_script("$('#business_contract_business_contract_versions_attributes_0_ending_date').val('#{(Date.today + 15).strftime("%d/%m/%Y")}')")

    click_on "Validation"
    sleep 2

    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert window.size > 1
  end

  test"Should redirect to business contract type cf page" do
    all('td', text: 'Convention de formation').first.click
    assert_selector 'h4', 'CONVENTION DE FORMATION'
  end

  test"Should redirect to business contract type ci page" do
    all('td', text: 'Contrat de prestation').first.click
    assert_selector 'h4', 'CONTRAT DE PRESTATION'
  end

  test"Should update business contract type cf data" do
    all('td', text: 'Convention de formation').first.click
    fill_in "business_contract_business_contract_versions_attributes_0_training_name", with: "Test update"
    click_on "Enregistrer"
    page.driver.browser.navigate.refresh
    assert_selector "input", "Test update"
  end

  test"Should update business contract type ci data" do
    all('td', text: 'Contrat de prestation').first.click
    fill_in "business_contract_business_contract_versions_attributes_0_mission_subject", with: "Test update"
    click_on "Enregistrer"
    page.driver.browser.navigate.refresh
    assert_selector "input", "Test update"
  end

  test "Should create new business contract version type cf" do
    all('td', text: 'Convention de formation').first.click
    version = find(".version-circle").text()
    accept_alert do
      click_on "Créer un avenant"
      sleep 1
    end
    sleep 1
    page.driver.browser.switch_to.alert.accept
    assert_equal version.to_i + 1, find(".version-circle").text().to_i
  end

  test "Should create new business contract version type ci" do
    all('td', text: 'Contrat de prestation').first.click
    version = find(".version-circle").text()
    accept_alert do
      click_on "Créer un avenant"
      sleep 1
    end
    sleep 1
    page.driver.browser.switch_to.alert.accept
    assert_equal version.to_i + 1, find(".version-circle").text().to_i
  end

  test "Should close business contract type cf" do
    all('td', text: 'Convention de formation').first.click
    click_on "Clôturer le contrat"
    assert_selector "div", "Contrat terminé"
  end

  test "Should close business contract type ci" do
    all('td', text: 'Contrat de prestation').first.click
    click_on "Clôturer le contrat"
    assert_selector "div", "Contrat terminé"
  end

  test "Should generate new business contract type cf document" do
    all('td', text: 'Convention de formation').first.click
    click_on "Imprimer"
    sleep 1
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert window.size > 1
  end

  test "Should generate new business contract type ci document" do
    all('td', text: 'Contrat de prestation').first.click
    click_on "Imprimer"
    sleep 1
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert window.size > 1
  end

  test "Should cancel close status business contract type cf" do
    all('td', text: 'Convention de formation').first.click
    click_on "Clôturer le contrat"
    click_on "Annuler la clôture du contrat"
    assert_selector "div", "Contrat validé"
  end

  test "Should cancel close status business contract type ci" do
    all('td', text: 'Contrat de prestation').first.click
    click_on "Clôturer le contrat"
    click_on "Annuler la clôture du contrat"
    assert_selector "div", "Contrat validé"
  end
end
