require "application_system_test_case"
require "goxygene_set_up"

class ConsultantNdfsTest < GoxygeneSetUp

  setup do
    visit goxygene.consultant_ndfs_path(Goxygene::Consultant.find(9392))
  end

  test "Should redirect to consultant salaries index" do
    assert_selector "h4", "NDF"
  end

  test "Should redirect to consultant ndf detail" do
    all('.list-table tbody tr').first.click
    assert_selector "h4", "Détail"
  end

  test "Should create new consultant ndf" do
    click_on "Créer une NDF"
    sleep 1

    execute_script("$('#expense_report_date').val('#{Date.today.strftime("%d/%m/%Y")}')")
    fill_in "expense_report_comment", with: "Test new"
    select "Formation", from: "expense_report_expense_report_details_attributes_0_expense_type_id"
    sleep 1
    fill_in "expense_report_expense_report_details_attributes_0_total_with_taxes", with: 100
    fill_in "expense_report_expense_report_details_attributes_0_vat", with: 100

    click_on "Enregistrer"
    assert_selector "td", "Test new"
  end

  test "Should update consultant ndf item" do
    find("td", text: "Bon à payer").click

    before = all("#expense-report-detail-items tr").size
    find(".fa-plus").click
    execute_script("$('tr:last .form-control').eq(0).val(1)")
    sleep 1
    execute_script("$('tr:last .form-control').eq(1).val(100)")
    execute_script("$('tr:last .form-control').eq(2).val(100)")

    click_on "Enregistrer"
    page.driver.browser.navigate.refresh

    assert_equal before + 1, all("#expense-report-detail-items tr").size
  end

  test "Should delete consultant ndf item" do
    find("td", text: "Bon à payer").click

    before = all("#expense-report-detail-items tr").size
    all(".fa-minus").first.click
    click_on "Enregistrer"
    page.driver.browser.navigate.refresh

    assert_equal before - 1, all("#expense-report-detail-items tr").size
  end

  test "Should delete consultant ndf 1 line" do
    accept_alert do
      execute_script('$("a[data-title=\"Supprimer la NDF\"]")[0].click()')
      sleep 1
    end
    sleep 2
    assert_selector "td", "Supprimée"
  end

  test "Should change consultant ndf status" do
    execute_script('$("a[data-title=\"A contrôler\"]")[0].click()')
    sleep 2
    assert_selector "td", "A contrôler"
  end

  test "Should export excel" do
    page.execute_script('$.find(".fa-file-excel-o")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH+"/expense_report.xlsx"
    assert File.exist?(full_path)
  end
end

