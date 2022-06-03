require "application_system_test_case"
require "goxygene_set_up"

class EstablishmentBusinessContractVersionsTest < GoxygeneSetUp

  setup do
    ActiveRecord::Migration.enable_extension "unaccent"
    visit goxygene.establishment_business_contracts_path(Goxygene::Establishment.find(9255))
  end

  test "Should edit a contrat de prestation and save" do
    all('td', text: 'Contrat de prestation').first.click
    fill_in "business_contract[business_contract_versions_attributes][0][time_length]", with: '2'
    fill_in "business_contract[business_contract_versions_attributes][0][notice_period]", with: '2'
    select "Taux intermédiaire - 10%", from: "business_contract[business_contract_versions_attributes][0][vat_id]"
    fill_in "business_contract[business_contract_versions_attributes][0][mission_subject]", with: "100"
    click_on "Enregistrer"
    sleep 2
    assert_input'#business_contract_business_contract_versions_attributes_0_time_length', 2.0
    assert_input'#business_contract_business_contract_versions_attributes_0_notice_period', 2
    assert_input'#business_contract_business_contract_versions_attributes_0_mission_subject', 100
    assert_selector "#business_contract_business_contract_versions_attributes_0_vat_id option[selected='selected']", text: "Taux intermédiaire - 10%"
  end

  test "Should edit a contrat formation and save" do
    all('td', text: 'Convention de formation').first.click
    fill_in "business_contract[business_contract_versions_attributes][0][training_days_before_deadline]", with: "20"
    select "Taux réduit - 5,50%", from: "business_contract[business_contract_versions_attributes][0][vat_id]"
    fill_in "business_contract[business_contract_versions_attributes][0][training_name]", with: "testing"
    fill_in "business_contract[business_contract_versions_attributes][0][training_purpose]", with: "TestingEdit"
    select "Action d'adaptation au poste de travail", from: "business_contract[business_contract_versions_attributes][0][training_target_id]"
    select "120 - Spécialités pluridisciplinaires, sciences humaines et droit", from: "business_contract[business_contract_versions_attributes][0][training_domain_id]"
    click_on "Enregistrer"
    sleep 2
    assert_input'#business_contract_business_contract_versions_attributes_0_training_days_before_deadline', 20
    assert_input'#business_contract_business_contract_versions_attributes_0_training_name', "testing"
    assert_input'#business_contract_business_contract_versions_attributes_0_training_purpose', "TestingEdit"
    assert_selector "#business_contract_business_contract_versions_attributes_0_vat_id option[selected='selected']", text: "Taux réduit - 5,50%"
    assert_selector "#business_contract_business_contract_versions_attributes_0_training_target_id option[selected='selected']", text: "Action d'adaptation au poste de travail"
    assert_selector "#business_contract_business_contract_versions_attributes_0_training_domain_id option[selected='selected']", text: "120 - Spécialités pluridisciplinaires, sciences humaines et droit"
  end

  test "Should create a new verion of contrat de prestation" do
    all('td', text: 'Contrat de prestation').first.click
    version = find("span.version-circle").text().to_i
    click_on "Créer un avenant"
    page.driver.browser.switch_to.alert.accept
    sleep 1
    page.driver.browser.switch_to.alert.accept
    sleep 2
    assert_equal version + 1, find("span.version-circle").text().to_i
  end

  test "Should create a new verion of contrat formation" do
    all('td', text: 'Convention de formation').first.click
    version = find("span.version-circle").text().to_i
    click_on "Créer un avenant"
    page.driver.browser.switch_to.alert.accept
    sleep 1
    page.driver.browser.switch_to.alert.accept
    sleep 2
    assert_equal version + 1, find("span.version-circle").text().to_i
  end

  test "Should close a contrat de prestation" do
    all('td', text: 'Contrat de prestation').first.click
    click_on "Clôturer le contrat"
    assert_selector "div", "Contrat terminé"
  end

  test "Should close a contrat formation" do
    all('td', text: 'Convention de formation').first.click
    click_on "Clôturer le contrat"
    assert_selector "div", "Contrat terminé"
  end

  test "Should cancel close a contrat de prestation" do
    all('td', text: 'Contrat de prestation').first.click
    click_on "Clôturer le contrat"
    click_on "Annuler la clôture du contrat"
    assert_selector "div", text: "Contrat validé"
    end

  test "Should cancel close a contrat formation" do
    all('td', text: 'Convention de formation').first.click
    click_on "Clôturer le contrat"
    click_on "Annuler la clôture du contrat"
    assert_selector "div", text: "Contrat validé"
  end

  test "Should success when generate a contrat de prestation pdf" do
    all('td', text: 'Contrat de prestation').first.click
    click_on "Imprimer"
    sleep 1
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert window.size > 1
  end

  test "Should success when generate a contrat formation pdf" do
    all('td', text: 'Convention de formation').first.click
    click_on "Imprimer"
    sleep 1
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert window.size > 1
  end
end
