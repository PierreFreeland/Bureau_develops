require "application_system_test_case"
require "goxygene_set_up"

class ClientTest < GoxygeneSetUp

  setup do
    visit goxygene.clients_path
  end

  test "Should redirect to client index page" do
    assert_selector "h4", "Suivi commercial"
  end

  test "Should redirect to client detail from client index" do
    all('tbody').first.all('tr').first.click
    assert_selector "h4", "TIMELINE"
  end

  test "Should create new client b2b" do
    click_on "Créer un Client B2B"
    fill_in "customer_tier_attributes_company_attributes_siren", with: "547154468"
    fill_in "customer_tier_attributes_company_attributes_corporate_name", with: "TEST CORPORATE NAME"
    click_on "Enregistrer"
    assert_selector "h4", "TEST CORPORATE NAME"
  end

  test "Should filter client b2b" do
    fill_in "q_tier_company_corporate_name_cont", with: "LYANLA"
    click_on "Rechercher"
    assert_selector "td", "LYANLA"
  end

  test "Should redirect to client company contacts from client index" do
    all('tbody').last.all('tr').first.click
    assert_selector "h4", "TIMELINE"
  end

end
