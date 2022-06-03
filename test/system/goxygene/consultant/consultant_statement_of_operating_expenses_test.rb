require "application_system_test_case"
require "goxygene_set_up"

class ConsultantStatementOfOperatingExpensesTest < GoxygeneSetUp

  setup do
    visit goxygene.consultant_statement_of_operating_expenses_path(Goxygene::Consultant.find(8786))
  end

  test "Should redirect to consultant operating expenses index" do
    assert_selector "h4", "DÉPENSES DE FONCTIONNEMENT"
  end

  test "Should redirect to consultant operating expenses detail" do
    all("tbody tr.clickable").first.click
    assert_selector "h4", "Détail"
  end

  test "Should update operating expenses line data" do
    all("tbody tr.clickable").first.click
    before = all("tr.fields").size

    # fill data
    find(".fa-plus").click
    sleep 1
    execute_script("$('tr:last .form-control').eq(0).val('01/02/2020')")
    execute_script("$('tr:last .form-control').eq(1).val(2)")
    execute_script("$('tr:last .form-control').eq(2).val(1000)")
    execute_script("$('tr:last .form-control').eq(3).val(1)")
    execute_script("$('tr:last .form-control').eq(4).val('Test')")
    click_on "Enregistrer"

    assert_equal before + 1, all("tr.fields").size
  end

  test "Should delete operating expenses line data" do
    all("tbody tr.clickable").first.click
    before = all("tr.fields").size
    all("tr.fields").first.hover
    accept_alert do
      execute_script("$('.da-reject')[0].click()")
    end
    assert_equal before - 1, all("tr.fields").size
  end

  test "Should generate ndf" do
    all("tbody tr.clickable").first.click
    click_on "Générer la NDF"
    assert_selector "h4", "NDF"
  end

  test "Should export excel" do
    page.execute_script('$.find(".fa-file-excel-o")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH+"/statement_of_operating_expenses.xlsx"
    assert File.exist?(full_path)
  end

  test "Should redirect to df requests from detail" do
    all("tbody tr.clickable").first.click
    click_on "Retour aux demandes de DF"
    assert_selector "h4", "DEMANDES DF"
  end

  test "Should redirect to consultant operating expenses index from detail" do
    all("tbody tr.clickable").first.click
    click_on "Retour aux DF du consultant"
    assert_selector "a", "Filtres"
  end
end

