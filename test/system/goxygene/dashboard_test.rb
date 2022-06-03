require "application_system_test_case"
require "goxygene_set_up"

class DashboardTest < GoxygeneSetUp
  setup do
    visit goxygene.root_path()
  end

  test "Should show data in header" do
    assert_selector "h4", text: "LES CHIFFRES #{Goxygene::Parameter.value_for_group}"
    assert_selector ".dashboard-figures span", text: "CA #{Time.current.year}"
    assert_selector ".dashboard-figures span", text: "PROSPECTS ACTIFS"
    assert_selector ".dashboard-figures span", text: "RECRUTEMENT #{Time.current.year}"
  end

  test "Should redirect to ITG Academy" do
    click_on "Académie #{Goxygene::Parameter.value_for_group}"
    sleep 2
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert window.size > 1
    # assert_selector ".have-sso-account"
  end

  test "Should redirect to ITG information" do
    click_on "#{Goxygene::Parameter.value_for_group} Formations"
    sleep 2
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert window.size > 1
    # assert_selector "h1", text: "Facturation de la formation"
  end

  test "Should redirect to Site internet ITG" do
    click_on "Site internet #{Goxygene::Parameter.value_for_group}"
    sleep 2
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert window.size > 1
    # assert_selector "h1", text: "ITG - Le Portage Salarial"
  end

  test "Should redirect to Collaborative platform" do
    click_on "Plateforme collaborative"
    sleep 2
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert window.size > 1
    # assert_selector "div", text: "CONNEXION"
  end

  test "Should redirect to news detail" do
    all('.actus-boxes').first.click
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert window.size > 1
  end

  test "Should redirect to total news page" do
    click_on "Toutes les actus"
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert window.size > 1
  end

  test "Should redirect to parameters article detail" do
    all('.info-boxes').first.click
    assert_selector "h4", text: "CONTENU"
    assert_selector "h4", text: "ETAT"
  end

  test "Should redirect to parameters article lists" do
    click_on "Plus d’actualités"
    assert_selector "h4", text: "ARTICLES"
  end
end
