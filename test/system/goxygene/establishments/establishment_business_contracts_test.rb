require "application_system_test_case"
require "goxygene_set_up"

class EstablishmentBusinessContractsTest < GoxygeneSetUp

  setup do
    ActiveRecord::Migration.enable_extension "unaccent"
    visit goxygene.establishment_business_contracts_path(Goxygene::Establishment.find(9255))
  end

  test "Should go to convention de formation when click a one of tab" do
    find("table.list-table tbody tr:first-child").click
    sleep 1
    assert_selector "li.active a", text: "CONTRATS COMMERCIAUX"
    assert_selector ".main h4", text: "CONVENTION DE FORMATION"
  end

  test "Should go to contrat de prestation when click a one of tab" do
    find("table.list-table tbody tr:nth-child(2)").click
    sleep 1
    assert_selector "li.active a", text: "CONTRATS COMMERCIAUX"
    assert_selector ".main h4", text: "CONTRAT DE PRESTATION"
  end

  test "Should filter a list" do
    click_on 'Filtres'
    select "Contrat de prestation", from: "q[type_eq]"
    click_on "Rechercher"
    assert_selector "li.active a", text: "CONTRATS COMMERCIAUX"
    assert_selector "table tbody tr:first-child td", text: "Contrat de prestation"
  end

  test "Should success when create a contrat commercial" do
    click_on "Créer un contrat commercial"
    find('[href*="type=ci"]').click

    find('#select2-business_contract_consultant_id-container').click
    find(:css, "input[class$='select2-search__field']").set("Kurtis")
    sleep 1
    find('ul:first-child li[role*="treeitem"]').click
    select "NUGON Ludovic- Grant Kurtis", from: 'business_contract[establishment_contact_id]'

    fill_in "business_contract[business_contract_versions_attributes][0][contract_sent_on]", with: Date.today.strftime("%d/%m/%Y")
    fill_in "business_contract[business_contract_versions_attributes][0][time_length]", with: "1"
    fill_in "business_contract[business_contract_versions_attributes][0][notice_period]", with: "1"
    fill_in "business_contract[business_contract_versions_attributes][0][order_amount]", with: "100"
    select "Taux normal - 20%", from: "business_contract[business_contract_versions_attributes][0][vat_id]"
    fill_in "business_contract[business_contract_versions_attributes][0][mission_subject]", with: "100"
    fill_in "business_contract[business_contract_versions_attributes][0][begining_date]", with: Date.today.strftime("%d/%m/%Y")
    fill_in "business_contract[business_contract_versions_attributes][0][ending_date]", with: (Date.today + 30).strftime("%d/%m/%Y")
    click_on "Validation"
    sleep 2

    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert window.size > 1
  end

  test "Should success when create a contrat formation" do
    click_on "Créer un contrat commercial"
    find('[href*="type=cf"]').click

    find('#select2-business_contract_consultant_id-container').click
    find(:css, "input[class$='select2-search__field']").set("Kurtis")
    sleep 1
    find('ul:first-child li[role*="treeitem"]').click
    select "NUGON Ludovic- Grant Kurtis", from: 'business_contract[establishment_contact_id]'

    fill_in "business_contract[business_contract_versions_attributes][0][contract_sent_on]", with: Date.today.strftime("%d/%m/%Y")
    fill_in "business_contract[business_contract_versions_attributes][0][training_days_before_deadline]", with: "20"
    fill_in "business_contract[business_contract_versions_attributes][0][order_amount]", with: "100"
    select "Taux réduit - 5,50%", from: "business_contract[business_contract_versions_attributes][0][vat_id]"
    fill_in "business_contract[business_contract_versions_attributes][0][training_name]", with: "testing"
    fill_in "business_contract[business_contract_versions_attributes][0][begining_date]", with: Date.today.strftime("%d/%m/%Y")
    fill_in "business_contract[business_contract_versions_attributes][0][ending_date]", with: (Date.today + 30).strftime("%d/%m/%Y")
    fill_in "business_contract[business_contract_versions_attributes][0][training_purpose]", with: "Tesing create"
    select "Action d'adaptation au poste de travail", from: "business_contract[business_contract_versions_attributes][0][training_target_id]"
    select "120 - Spécialités pluridisciplinaires, sciences humaines et droit", from: "business_contract[business_contract_versions_attributes][0][training_domain_id]"
    click_on "Validation"
    sleep 2

    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert window.size > 1
  end
end
