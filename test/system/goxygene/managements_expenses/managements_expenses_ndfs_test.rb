require "application_system_test_case"
require "goxygene_set_up"

class ManagementsExpensesNdfsTest < GoxygeneSetUp

  test "Should export excel on ndfs list page" do
    visit goxygene.managements_ndfs_path
    page.execute_script('$.find(".text-green")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH+"/managements_ndfs.xlsx"
    assert File.exist?(full_path)
  end

  test "Should redirect to managements expenses ndfs detail" do
    visit goxygene.managements_ndfs_path
    page.all('tr')[1].click
    assert_selector "h4", "Détail"
  end

  test "Should update data on detail page" do
    visit goxygene.managements_ndf_path(Goxygene::ExpenseReport.find(270762))
    before = page.all('tr').count
    execute_script("$('.fa-minus')[0].click()")
    click_on 'Enregistrer'
    sleep 2
    assert_equal before - 1, page.all('tr').count
  end

  test "Should change status after click NDF à contrôler" do
    visit goxygene.managements_ndfs_path
    execute_script("$('input[data-id=270762]').click()")
    click_on 'NDF à contrôler'
    sleep 3
    assert_equal 'to_be_checked', Goxygene::ExpenseReport.find(270762).disbursement_source_status
  end
end
