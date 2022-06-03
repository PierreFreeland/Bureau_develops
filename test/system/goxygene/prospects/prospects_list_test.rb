require "application_system_test_case"
require "goxygene_set_up"

class ProspectsListTest < GoxygeneSetUp

  setup do
    visit goxygene.prospects_path
  end

  def filter_status
    all(".fa-filter").first.click
    sleep 1
    all(".select2-container")[1].click
    sleep 1
    all(".select2-results__option")[0].click
    click_on "Rechercher"
  end

  test "Should redirect to prospects list page" do
    assert_selector "h4", "SUIVI PROSPECTS"
  end

  test "Should filter prospect lists by status" do
    filter_status
    assert all("tr[data-clickable-url]").present?
  end

  test "Should reset prospects list filter" do
    filter_status
    all(".fa-filter").first.click
    sleep 2
    click_on "Réinitialiser les filtres"
    assert all("tr[data-clickable-url]").empty?
  end

  test "Should redirect to prospect notification" do
    all("a", text: "Voir plus").first.click
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert_selector "h4", "MES NOTIFICATIONS"
  end

  test "Should redirect to prospect pending formations" do
    all("a", text: "Voir plus").last.click
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert_selector "h4", "INSCRIPTIONS FORMATIONS EN ATTENTE"
  end

  test "Should redirect to consultant registers" do
    find(:xpath, "//a[@href='/goxygene/consultants/registers']").click
    assert_selector "h4", "RH"
  end

  test "Should create prospect's call action" do
    filter_status
    execute_script('$("a[data-target=\"#modal-utilities\"]")[0].click()')
    sleep 1
    assert_selector "h4", "NOUVELLE ACTION"
  end

end
