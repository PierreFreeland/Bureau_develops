require "application_system_test_case"
require "goxygene_set_up"

class ManagementPaymentHistoryTest < GoxygeneSetUp

  setup do
    visit goxygene.managements_payment_history_index_path
    click_on "Filtres"
    assert_selector "label", "Dates"

    select "Montgomery conseil", from: "q_itg_company_id_eq"
    click_on "Rechercher"
  end

  test "Should filter data" do
    assert page.all('table.list-table tr').count > 1
  end

  test "Should redirect to payment history detail" do
    page.all('tr')[1].click
    assert_selector "label", text: "Type de paiment"
  end

  test "Should redirect to establishment client page" do
    within ".clickable" do
      all('td')[7].click
    end
    assert_selector "h4", "LES INFOS CLÉS"
    sleep 7
  end

  test "Should export payment history file" do
    page.execute_script('$.find(".text-green")[0].click()')
    full_path = DOWNLOAD_PATH+"/managements_payment_history.xlsx"
    sleep 3
    assert File.exist?(full_path)
  end

end
