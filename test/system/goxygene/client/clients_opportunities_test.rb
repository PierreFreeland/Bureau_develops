require "application_system_test_case"
require "goxygene_set_up"

class ClientsOpportunitiesTest < GoxygeneSetUp

  setup do
    visit goxygene.client_opportunities_path(Goxygene::Customer.first)
  end

  test "Should redirect to client opportunities index page" do
    assert_selector "h4", "OPPORTUNITÉS"
  end

  test "Should open create client opportunities modal" do
    click_on "Créer une opportunité"
    assert_selector "h4", "CRÉATION D'UNE OPPORTUNITÉ"
  end

  test "Should have validate business opportunity name message" do
    click_on "Créer une opportunité"
    sleep 1
    select all("#business_opportunity_framework_agreement_type_id option").last.text, from: "business_opportunity_framework_agreement_type_id"
    fill_in "business_opportunity_income", with: "1000"
    select all("#business_opportunity_business_opportunity_origin_id option").last.text, from: "business_opportunity_business_opportunity_origin_id"
    execute_script("$('#business_opportunity_begining_date').val('#{Date.today.strftime("%d/%m/%Y")}')")
    execute_script("$('#business_opportunity_ending_date').val('#{(Date.today + 15).strftime("%d/%m/%Y")}')")
    click_on "Enregistrer"
    assert_selector ".alert-danger", "Objet doit être rempli(e)"
  end

  test "Should have validate business opportunity framework agreement type message" do
    click_on "Créer une opportunité"
    fill_in "business_opportunity_name", with: "Test opportunity"
    fill_in "business_opportunity_income", with: "1000"
    select all("#business_opportunity_business_opportunity_origin_id option").last.text, from: "business_opportunity_business_opportunity_origin_id"
    execute_script("$('#business_opportunity_begining_date').val('#{Date.today.strftime("%d/%m/%Y")}')")
    execute_script("$('#business_opportunity_ending_date').val('#{(Date.today + 15).strftime("%d/%m/%Y")}')")
    click_on "Enregistrer"
    assert_selector ".alert-danger", "Type projet doit exister"
  end

  test "Should have validate business opportunity income message" do
    click_on "Créer une opportunité"
    fill_in "business_opportunity_name", with: "Test opportunity"
    select all("#business_opportunity_framework_agreement_type_id option").last.text, from: "business_opportunity_framework_agreement_type_id"
    select all("#business_opportunity_business_opportunity_origin_id option").last.text, from: "business_opportunity_business_opportunity_origin_id"
    execute_script("$('#business_opportunity_begining_date').val('#{Date.today.strftime("%d/%m/%Y")}')")
    execute_script("$('#business_opportunity_ending_date').val('#{(Date.today + 15).strftime("%d/%m/%Y")}')")
    click_on "Enregistrer"
    assert_selector ".alert-danger", "CA ht doit être rempli(e)"
  end

  test "Should have validate business opportunity origin message" do
    click_on "Créer une opportunité"
    fill_in "business_opportunity_name", with: "Test opportunity"
    select all("#business_opportunity_framework_agreement_type_id option").last.text, from: "business_opportunity_framework_agreement_type_id"
    fill_in "business_opportunity_income", with: "1000"
    execute_script("$('#business_opportunity_begining_date').val('#{Date.today.strftime("%d/%m/%Y")}')")
    execute_script("$('#business_opportunity_ending_date').val('#{(Date.today + 15).strftime("%d/%m/%Y")}')")
    click_on "Enregistrer"
    assert_selector ".alert-danger", "Origine doit exister"
  end

  test "Should have validate business opportunity begining date message" do
    click_on "Créer une opportunité"
    fill_in "business_opportunity_name", with: "Test opportunity"
    select all("#business_opportunity_framework_agreement_type_id option").last.text, from: "business_opportunity_framework_agreement_type_id"
    fill_in "business_opportunity_income", with: "1000"
    select all("#business_opportunity_business_opportunity_origin_id option").last.text, from: "business_opportunity_business_opportunity_origin_id"
    execute_script("$('#business_opportunity_ending_date').val('#{(Date.today + 15).strftime("%d/%m/%Y")}')")
    click_on "Enregistrer"
    assert_selector ".alert-danger", "Début de projet doit être rempli(e)"
  end

  test "Should have validate business opportunity ending date message" do
    click_on "Créer une opportunité"
    fill_in "business_opportunity_name", with: "Test opportunity"
    select all("#business_opportunity_framework_agreement_type_id option").last.text, from: "business_opportunity_framework_agreement_type_id"
    fill_in "business_opportunity_income", with: "1000"
    select all("#business_opportunity_business_opportunity_origin_id option").last.text, from: "business_opportunity_business_opportunity_origin_id"
    execute_script("$('#business_opportunity_begining_date').val('#{Date.today.strftime("%d/%m/%Y")}')")
    click_on "Enregistrer"
    assert_selector ".alert-danger", "Fin de projet doit être rempli(e)"
  end

  test "Should create new business opportunity" do
    click_on "Créer une opportunité"
    fill_in "business_opportunity_name", with: "Test opportunity"
    select all("#business_opportunity_framework_agreement_type_id option").last.text, from: "business_opportunity_framework_agreement_type_id"
    fill_in "business_opportunity_income", with: "1000"
    select all("#business_opportunity_business_opportunity_origin_id option").last.text, from: "business_opportunity_business_opportunity_origin_id"
    execute_script("$('#business_opportunity_begining_date').val('#{Date.today.strftime("%d/%m/%Y")}')")
    execute_script("$('#business_opportunity_ending_date').val('#{(Date.today + 15).strftime("%d/%m/%Y")}')")
    click_on "Enregistrer"
    assert_selector "#business_opportunity_name", "Test opportunity"
  end

  test "Should redirect to client opportunities detail page" do
    all('tbody tr').first.click
    assert_selector "h4", "PROJET"
  end

  test "Should update client opportunities data" do
    all('tbody tr').first.click
    fill_in "business_opportunity_name", with: "Test update name"
    click_on "Enregistrer"
    page.driver.browser.navigate.refresh
    assert_selector "#business_opportunity_name", "Test update name"
  end

  test "Should update client opportunities document" do
    all('tbody tr').first.click
    file_path = File.absolute_path('./test/fixtures/files/sample1.pdf')
    all('a .fa-plus').first.click
    attach_file(all("input[type='file']").first[:id], file_path)
    click_on "Enregistrer"
    assert_selector "a", "sample1.pdf"
  end

  test "Should delete client opportunities document" do
    all('tbody tr').first.click
    file_path = File.absolute_path('./test/fixtures/files/sample1.pdf')
    all('a .fa-plus').first.click
    attach_file(all("input[type='file']").first[:id], file_path)
    click_on "Enregistrer"
    sleep 1

    find(".fa-minus").click
    click_on "Enregistrer"
    assert page.has_no_content?("sample1.pdf")
  end

  test "Should update client opportunities prospect" do
    all('tbody tr').first.click
    all('a .fa-plus').last.click
    sleep 1
    all('.select2')[0].click
    find(:css, "input[class$='select2-search__field']").set("Richard")
    sleep(1)
    all('.select2-results__option')[0].click
    click_on "Enregistrer"

    assert_selector "a", "Lemay Richard"
  end

  test "Should delete client opportunities prospect" do
    all('tbody tr').first.click
    all('a .fa-plus').last.click
    sleep 1
    all('.select2')[0].click
    find(:css, "input[class$='select2-search__field']").set("Richard")
    sleep(1)
    all('.select2-results__option')[0].click
    click_on "Enregistrer"
    sleep 1

    find(".fa-minus").click
    click_on "Enregistrer"
    assert page.has_no_content?("Lemay Richard")
  end

  test "Should create framework agreement from client opportunities" do
    all('tbody tr').first.click
    click_on "Générer le contrat-cadre"
    sleep 1
    select "En traitement", from: "framework_agreement_framework_agreement_status"
    click_on "Enregistrer"
    assert_selector "h4", "DONNÉES CONTRAT-CADRE"
  end

end
