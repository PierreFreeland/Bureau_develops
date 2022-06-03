require "application_system_test_case"
require "goxygene_set_up"

class EstablishmentAccountsTest < GoxygeneSetUp

  setup do
    visit goxygene.establishment_accounts_path(Goxygene::Establishment.last)
    assert_selector 'h4', text: 'COMPTABILITÉ'
  end

  test "Should show table" do
    assert_selector "th", text: "DATE OPÉRATION"
    assert_selector "th", text: "PIÈCE"
    assert_selector "th", text: "LIBELLÉ"
    assert_selector "th", text: "DÉBIT"
    assert_selector "th", text: "CRÉDIT"
    assert_selector "th", text: "SOLDE"
  end

  test "Should export excel" do
    page.execute_script('$.find(".text-green")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH+"/accounting_entry.xlsx"
    assert File.exist?(full_path)
  end
end