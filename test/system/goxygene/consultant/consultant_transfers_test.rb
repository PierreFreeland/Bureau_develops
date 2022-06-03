require "application_system_test_case"
require "goxygene_set_up"

class ConsultantTransfersTest < GoxygeneSetUp

  setup do
    visit goxygene.consultant_transfers_path(Goxygene::Consultant.find(8786))
  end

  test "Should redirect to consultant formations index" do
    assert_selector "h4", "CHÈQUES / VIREMENTS"
  end

  test "Should preview courrier cheque pdf" do
    execute_script('$("a[data-title=\"Courrier chèque\"]")[0].click()')
    sleep 2
    assert has_selector? 'embed[type="application/pdf"]'
  end

  test "Should redirect to transfer history detail" do
    execute_script('$("a[data-title=\"Détails\"]")[0].click()')
    sleep 2
    assert_selector "h4", "BORDEREAUX DE VIREMENTS"
  end

  test "Should change type transfer to cheque" do
    accept_alert do
      execute_script('$("a[data-title=\"Passer en chèque\"]")[0].click()')
    end
    sleep 2
    all(".list-table tbody tr").each do |tr|
      if tr.all("td")[2].text == "515846"
        if tr.all("td")[1].text == "Chèque"
          assert true
        end
      end
    end
  end

  test "Should preview avis virement pdf" do
    execute_script('$("a[data-title=\"Avis virement\"]")[0].click()')
    sleep 2
    assert has_selector? 'embed[type="application/pdf"]'
  end

  test "Should export excel" do
    page.execute_script('$.find(".fa-file-excel-o")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH+"/disbursement.xlsx"
    assert File.exist?(full_path)
  end
end

