require "application_system_test_case"
require "goxygene_set_up"

class ClientAffiliatesTest < GoxygeneSetUp

  setup do
    visit goxygene.client_affiliates_path(Goxygene::Customer.first)
  end

  test "Should redirect to client affiliates page" do
    assert_selector "h4", "FILIALES"
  end

  test "Should open create client affiliates modal" do
    click_on "Ajouter une filiale"
    assert_selector "h4", "AJOUTER UNE FILIALE"
  end

  test "Should create new client affiliates" do
    click_on "Ajouter une filiale"
    sleep 1
    all('.select2')[0].click
    find(:css, "input[class$='select2-search__field']").set("GENERALI")
    sleep 1
    all('.select2-results__option')[0].click
    sleep 1
    click_on "Enregistrer"
    assert_selector "td", "GENERALI"
  end

  test "Should redirect to client affiliates timeline" do
    find('tr', text: 'Selarl Radiologie Saint-Paul').click
    assert_selector "h4", "Selarl Radiologie Saint-Paul"
  end

  test "Should delete link with client affiliates" do
    before = page.all("tbody tr").size
    accept_alert do
      sleep 1
      execute_script('$("a.rounded-icons[data-method=\"delete\"]")[0].click()')
    end
    assert_equal before - 1, page.all("tbody tr").size
  end
end
