require "application_system_test_case"
require "goxygene_set_up"

class ManagementClientTransfersTest < GoxygeneSetUp
  test "Should redirect to index" do
    skip
    visit goxygene.managements_client_transfers_path
    assert_selector 'h4', 'VIREMENTS CLIENT'
  end

  test "Should open collapse to create" do
    skip
    visit goxygene.managements_client_transfers_path
    click_on "Ajouter un virement"
    assert_selector 'input', 'Enregistrer'
  end

  test "Should open collapse filter" do
    skip
    visit goxygene.managements_client_transfers_path
    click_on "Filtres"
    assert_selector 'input', 'Rechercher'
  end

  test "Should open modal for Import cfonb" do
    skip
    visit goxygene.managements_client_transfers_path
    click_on "Importer"
    sleep(2)
    assert_selector 'label', 'Import CFONB'
  end

  test "Should redirect to establishment payment after click name" do
    skip
    visit goxygene.managements_client_transfers_path
    click_on "LYANLA"
    sleep(20)
    assert_selector 'h4', 'ENCAISSEMENT'
  end

  test "Should create payments" do
    visit goxygene.managements_client_transfers_path
    click_on "Ajouter un virement"

    fill_in 'customer_payment[amount_euros]', with: 100

    all('.select2')[0].click
    find(:css, "input[class$='select2-search__field']").set("lyanla")
    sleep(1)
    all('.select2-results__option')[0].click

    within ".itg-company-select-manager" do
      all('option')[2].click
    end

    within ".itg-bank-account" do
      all('option')[1].click
    end

    click_on 'Enregistrer'
    within '.list-table' do
      assert_equal all('tr').size - 1, Goxygene::CustomerPayment.all.transfers.count
    end
  end

  test "Should redirect to edit payment" do
    visit goxygene.managements_client_transfers_path
    within '.list-table' do
      all('tr')[1].click
    end
    assert_selector 'h4', 'Modifier le règlement'
  end
  #
  test "Should delete the data" do
    visit goxygene.managements_client_transfers_path
    within '.list-table' do
      all('.rounded-icons')[1].click
    end
    page.driver.browser.switch_to.alert.accept

    within '.list-table' do
      assert_equal all('tr').size - 1, Goxygene::CustomerPayment.all.transfers.count
    end
  end

end