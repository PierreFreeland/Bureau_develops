require "application_system_test_case"
require "goxygene_set_up"

class ManagementClientChequesTest < GoxygeneSetUp
  test "Should open collapse to create" do
    visit goxygene.managements_client_cheques_path
    click_on "Ajouter un chèque"
    assert_selector 'input', 'Enregistrer'
  end

  test "Should create" do
    visit goxygene.managements_client_cheques_path
    click_on "Ajouter un chèque"
    assert_selector 'input', 'Enregistrer'
    sleep 5
    within "#customer_payment_itg_company_id" do
      all('option')[1].click
    end
    click_on "Enregistrer"
    within '.list-table' do
      assert_equal all('tr').size, Goxygene::CustomerPayment.all.checks.count
    end
  end

  test "Should open collapse filter" do
    visit goxygene.managements_client_cheques_path
    click_on "Filtres"
    assert_selector 'input', 'Rechercher'
  end

  test "Should redirect to client cheque detail" do
    visit goxygene.managements_client_cheques_path
    page.all('tr')[1].click
    assert_selector "h4", text: "Factures réglées"
  end

  test "Should export client cheques file" do
    visit goxygene.managements_client_cheques_path
    page.execute_script('$.find(".text-green")[0].click()')
    full_path = DOWNLOAD_PATH+"/managements_client_cheques.xlsx"
    sleep 3
    assert File.exist?(full_path)
  end
end