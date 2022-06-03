require "application_system_test_case"
require "goxygene_set_up"

class EstablishmentBillingsTest < GoxygeneSetUp

  setup do
    ActiveRecord::Migration.enable_extension "unaccent"
    visit goxygene.establishment_billings_path(Goxygene::Establishment.find(12517))
  end

  test "Should filter a list" do
    select "Facture", from: "q[bill_type_eq]"
    click_on "Rechercher"
    sleep 2
    assert_selector "li.active a", text: "FACTURES"
    assert_selector "td", text: "Gutkowski"
  end

  test "Should go to management billing when click a one of tab" do
    find("table tbody tr:first-child").click
    sleep 2
    assert_selector "li.active a", text: "FACTURATION"
    assert_selector ".main h4", text: "DÉTAILS"
  end

  test "Should go to consultant" do
    find("table tbody tr:first-child a[href*='consultants']").click
    sleep 2
    assert_selector "li.active a", text: "TIMELINE"
    assert_selector "h4", text: "LES INFOS CLÉS"
  end

  test "Should open a pdf" do
    find("table tbody tr:first-child a[href*='preview_pdf']").click
    sleep 1
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert window.size > 1
  end

  test "Should export a excel" do
    page.execute_script('$.find(".text-green")[0].click()')
    sleep 3
    full_path = DOWNLOAD_PATH+"/bill.xlsx"
    assert File.exist?(full_path)
  end
end
