require "application_system_test_case"
require "goxygene_set_up"

class ConsultantBillingsTest < GoxygeneSetUp

  setup do
    visit goxygene.consultant_billings_path(Goxygene::Consultant.find(9392))
  end

  test "Should redirect to consultant billings index" do
    assert_selector "h4", "FACTURATION"
  end

  test "Should redirect to consultant billings create" do
    click_on "Créer une facture"
    assert_selector "h4", "CRÉATION D’UNE FACTURE DE PORTAGE SALARIALE"
  end

  test "Should redirect to billings detail" do
    all("tbody tr.clickable").first.all("td").first.click
    assert_selector "a", "Retourner à la liste des factures"
  end

  test "Should redirect back to consultant billings" do
    all("tbody tr.clickable").first.all("td").first.click
    click_on "Retourner à la liste des factures"
    assert_selector "h4", "FACTURATION"
  end

  test "Should redirect ot establishment timeline" do
    all("tbody td.exclude-clickable").first.click
    assert_selector "a.text-orange", "Établissements"
  end

  test "Should create new consultant billing" do
    click_on "Créer une facture"

    # fill consultant select2
    all('.select2')[0].click
    find(:css, "input[class$='select2-search__field']").set("lyanla")
    sleep(1)
    all('.select2-results__option')[0].click

    # fill customer bill detail
    within ".bill-detail-type" do
      all('option')[2].click
    end
    fill_in 'customer_bill[customer_bill_details_attributes][0][label]', with: 'test'
    fill_in 'customer_bill[customer_bill_details_attributes][0][amount]', with: 100

    click_on 'Enregistrer'
    assert_selector 'h4', 'DÉTAILS'
  end

  test "Should export excel" do
    page.execute_script('$.find(".fa-file-excel-o")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH+"/customer_bills.xlsx"
    assert File.exist?(full_path)
  end

end

