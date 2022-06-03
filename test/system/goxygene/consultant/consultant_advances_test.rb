require "application_system_test_case"
require "goxygene_set_up"

class ConsultantAdvancesTest < GoxygeneSetUp

  setup do
    visit goxygene.consultant_advances_path(Goxygene::Consultant.find(8786))
  end

  test "Should redirect to consultant advances index" do
    assert_selector "h4", "AVANCES"
  end

  test "Should create new consultant advance" do
    click_on "Créer une avance"
    sleep 1
    fill_in "wage_advance_correspondant_comment", with: "Test"
    fill_in "wage_advance_amount", with: "10"
    all("input[value='Enregistrer']").first.click
    assert_selector "td", "Test"
  end

  test "Should delete consultant advance data" do
    before = all("tbody tr").size
    accept_alert do
      execute_script("$('.fa-trash')[0].click()")
    end

    assert_equal before - 1, all("tbody tr").size
  end

  test "Should update consultant advance data" do
    fill_in "consultant_wage_advances_attributes_1_amount", with: "10000"
    all("input[value='Enregistrer']").last.click
    page.driver.browser.navigate.refresh
    assert_selector "input", "10000"
  end

  test "Should export excel" do
    page.execute_script('$.find(".fa-file-excel-o")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH+"/cash_accounting_entries.xlsx"
    assert File.exist?(full_path)
  end
end

