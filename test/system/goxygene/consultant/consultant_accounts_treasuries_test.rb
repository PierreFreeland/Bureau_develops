require "application_system_test_case"
require "goxygene_set_up"

class ConsultantAccountsTreasuriesTest < GoxygeneSetUp
  setup do
    visit goxygene.consultant_treasuries_accounts_path(Goxygene::Consultant.find(8786))
    assert_selector "h4", text: "TRÉSO"
  end

  test "Should show table" do
    assert_selector "th", text: "DATE OPÉRATION"
    assert_selector "th", text: "PIÈCE"
    assert_selector "th", text: "LIBELLÉ"
    assert_selector "th", text: "DÉBIT"
    assert_selector "th", text: "CRÉDIT"
    assert_selector "th", text: "SOLDE"
    assert_selector "th", text: "LETTRAGE"
    assert_selector "th", text: "JOURNAL"
  end

  test "Should export excel" do
    page.execute_script('$.find(".text-green")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH+"/consultants_advance.xlsx"
    assert File.exist?(full_path)
  end
end