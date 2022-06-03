require "application_system_test_case"
require "goxygene_set_up"

class ConsultantAccountsInfosTest < GoxygeneSetUp
  setup do
    ActiveRecord::Migration.enable_extension "unaccent"
    visit goxygene.consultant_business_contract_index_path(Goxygene::Consultant.find(8786))
    assert_selector "h4", text: "CONTRATS COMMERCIAUX"
  end

  test "Should redirect and show siret error when create business contract type ci" do
    click_on "Créer un contrat commercial"
    click_on "Contrat de prestation"

    sleep 1
    find('#select2-business_contract_establishment_id-container').click
    find(:css, "input[class$='select2-search__field']").set("HSBC France")
    sleep 2
    find('ul:first-child li:first-child[role*="treeitem"]').click
    select "Honigman Philippe- Gutkowski Drew", from: 'business_contract[establishment_contact_id]'
    sleep 2
    select all("#business_contract_establishment_contact_id option").last.text, from: "business_contract_establishment_contact_id"
    execute_script("$('#business_contract_business_contract_versions_attributes_0_contract_sent_on').val('#{Date.today.strftime("%d/%m/%Y")}')")
    sleep 2
    fill_in "business_contract_business_contract_versions_attributes_0_notice_period", with: "10"
    fill_in "business_contract_business_contract_versions_attributes_0_order_amount", with: "100"
    fill_in "business_contract_business_contract_versions_attributes_0_mission_subject", with: "test"
    execute_script("$('#business_contract_business_contract_versions_attributes_0_begining_date').val('#{Date.today.strftime("%d/%m/%Y")}')")
    execute_script("$('#business_contract_business_contract_versions_attributes_0_ending_date').val('#{(Date.today + 15).strftime("%d/%m/%Y")}')")

    click_on "Validation"

    assert_selector "li", text: "Le champ SIRET doit être renseigné ou le champ Personne physique doit être coché."
  end

  test "Should redirect and show siret error create business contract type cf" do
    click_on "Créer un contrat commercial"
    click_on "Convention de formation"

    sleep 1
    find('#select2-business_contract_establishment_id-container').click
    find(:css, "input[class$='select2-search__field']").set("HSBC France")
    sleep 2
    find('ul:first-child li:first-child[role*="treeitem"]').click
    select "Honigman Philippe- Gutkowski Drew", from: 'business_contract[establishment_contact_id]'
    sleep 2
    execute_script("$('#business_contract_business_contract_versions_attributes_0_contract_sent_on').val('#{Date.today.strftime("%d/%m/%Y")}')")
    sleep 2
    fill_in "business_contract_business_contract_versions_attributes_0_training_days_before_deadline", with: "2"
    fill_in "business_contract_business_contract_versions_attributes_0_order_amount", with: "100"
    fill_in "business_contract_business_contract_versions_attributes_0_training_name", with: "test"
    fill_in "business_contract_business_contract_versions_attributes_0_training_purpose", with: "test"
    select "Action d'adaptation au poste de travail", from: 'business_contract[business_contract_versions_attributes][0][training_target_id]'
    select "110 - Spécialités pluriscientifiques", from: 'business_contract[business_contract_versions_attributes][0][training_domain_id]'
    execute_script("$('#business_contract_business_contract_versions_attributes_0_begining_date').val('#{Date.today.strftime("%d/%m/%Y")}')")
    execute_script("$('#business_contract_business_contract_versions_attributes_0_ending_date').val('#{(Date.today + 15).strftime("%d/%m/%Y")}')")

    click_on "Validation"
    assert_selector "li", text: "Le champ SIRET doit être renseigné ou le champ Personne physique doit être coché."
  end

  test "Should create new contact" do
    click_on "Créer un contrat commercial"
    click_on "Convention de formation"

    sleep 1
    find('#select2-business_contract_establishment_id-container').click
    find(:css, "input[class$='select2-search__field']").set("HSBC France")
    sleep 1
    find('ul:first-child li:first-child[role*="treeitem"]').click
    # select "Honigman Philippe- Gutkowski Drew", from: 'business_contract[establishment_contact_id]'
    click_on "Ajouter un nouveau contact"
    sleep 2
    assert_selector "h4", "Ajouter un nouveau contact"
    fill_in "establishment_contact_individual_attributes_last_name", with: "test"
    click_on "Enregistrer"

    sleep 2
    assert_selector "option", text: "test - Gutkowski Drew"
  end
end