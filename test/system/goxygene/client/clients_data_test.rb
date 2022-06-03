require "application_system_test_case"
require "goxygene_set_up"

class ClientsDataTest < GoxygeneSetUp

  setup do
    visit goxygene.client_data_path(Goxygene::Customer.last)
  end

  test "Should redirect to client data page" do
    assert_selector "h4", "DONNÉES CLIENT"
  end

  test "Should update client customer maison-mère data" do
    # fill Maison-mère select2
    all('.select2')[0].click
    find(:css, "input[class$='select2-search__field']").set("HSB")
    sleep(1)
    all('.select2-results__option')[0].click

    click_on "Enregistrer"
    page.driver.browser.navigate.refresh

    assert_selector "span", "HSBC"
  end

  test "Should update client customer legal form data" do
    within "#customer_tier_attributes_company_attributes_legal_form_id" do
      all("#customer_tier_attributes_company_attributes_legal_form_id option").first.click
    end
    click_on "Enregistrer"
    page.driver.browser.navigate.refresh

    assert_selector "span", all("#customer_tier_attributes_company_attributes_legal_form_id option").first.text
  end

  test "Should update client customer line of business data" do
    within "#customer_tier_attributes_company_attributes_line_of_business_id" do
      all("#customer_tier_attributes_company_attributes_line_of_business_id option").first.click
    end
    click_on "Enregistrer"
    page.driver.browser.navigate.refresh

    assert_selector "span", all("#customer_tier_attributes_company_attributes_line_of_business_id option").first.text
  end

  test "Should update client customer employee data" do
    within ".panel-body #customer_employee_id" do
      all(".panel-body #customer_employee_id option").first.click
    end
    click_on "Enregistrer"
    page.driver.browser.navigate.refresh

    assert_selector "span", all(".panel-body #customer_employee_id option").first.text
  end

  test "Should have validate client customer siren format error" do
    fill_in "customer_tier_attributes_company_attributes_siren", with: "123"
    click_on "Enregistrer"
    assert_selector ".alert-danger", "Le SIREN doit être composé de 9 chiffres."
  end

  test "Should have validate client customer siren invalid error" do
    fill_in "customer_tier_attributes_company_attributes_siren", with: "123456789"
    click_on "Enregistrer"
    assert_selector ".alert-danger", "Le SIREN n'est pas valide"
  end

  test "Should update client customer siren data" do
    fill_in "customer_tier_attributes_company_attributes_siren", with: "472225200"
    click_on "Enregistrer"
    assert_selector "input", "472225200"
  end

  test "Should update client contact datum with france" do
    # fill Zipcode select2
    all('.select2')[1].click
    find(:css, "input[class$='select2-search__field']").set("040")
    sleep(1)
    all('.select2-results__option')[0].click

    click_on "Enregistrer"
    page.driver.browser.navigate.refresh

    assert_selector "input", "AMBERIEUX EN DOMBES"
  end

  test "Should update client contact datum with other country" do
    select "AFGHANISTAN", from: "customer_tier_attributes_company_attributes_contact_datum_attributes_country_id"
    fill_in "customer_tier_attributes_company_attributes_contact_datum_attributes_city", with: "Test city"
    click_on "Enregistrer"
    page.driver.browser.navigate.refresh
    assert_selector "input", "Test city"
  end

  test "Should update client customer referenced on info clés" do
    page.find('#customer_referenced', visible: :all).set(false)
    click_on "Enregistrer"
    page.driver.browser.navigate.refresh
    assert_equal false, page.find('#customer_referenced', visible: :all).checked?
  end

  test "Should update client customer comment on info clés" do
    fill_in "customer_comment", with: "Test memo"
    click_on "Enregistrer"
    page.driver.browser.navigate.refresh
    assert_selector "textarea", "Test memo"
  end

  test "Client customer corporate name on info clés should match when update" do
    fill_in "customer_tier_attributes_company_attributes_corporate_name", with: "Test corporate name"
    click_on "Enregistrer"
    page.driver.browser.navigate.refresh
    assert_selector ".info-box div", "Test corporate name"
  end
end
