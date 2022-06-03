require "application_system_test_case"
require "goxygene_set_up"

class ConsultantsUpdateTest < GoxygeneSetUp

  setup do
    visit goxygene.consultants_update_contracts_path
  end

  test"Should redirect to consultant update" do
    sleep 3
    assert_selector "h4", "DEMANDES DE MISE À JOUR "
  end

  test "Should filter Conseiller de gestion on consultant name from consultant update" do
    find(".fa-filter").click
    sleep 1
    all(".selection-counter")[0].click
    sleep 1
    selected_consultant = all(".select2-results__option")[0]
    all(".select2-results__option")[1].click
    click_on "Rechercher"

    result = []
    all(".list-table tbody tr").each do |tr|
      if selected_consultant.include?(tr.all("a")[0].text)
        result << true
      else
        result << false
      end
    end
    assert !result.include?(false)
  end

  test "Should click check button" do
    all("tbody tr.clickable-remote-modal").first.all("td").first.hover
    find(".fa-check").click
    page.driver.browser.switch_to.alert.accept
    sleep 1
    assert_selector "h4", "DEMANDES DE MISE À JOUR"
  end

  test "Should click delete button" do
    all("tbody tr.clickable-remote-modal").first.all("td").first.hover
    find(".fa-ban").click
    page.driver.browser.switch_to.alert.accept
    sleep 1
    assert_selector "h4", "DEMANDES DE MISE À JOUR"
  end

  test "Should open modal" do
    all("tbody tr.clickable-remote-modal").first.all("td").first.click
    assert_selector "h4", "VÉRIFICATION AVANT VALIDATION"
  end

  test "Should open modal click Annuler" do
    all("tbody tr.clickable-remote-modal").first.all("td").first.click
    click_on "Annuler"
    assert_selector "h4", "DEMANDES DE MISE À JOUR"
  end

  test "Should open modal click Rejeter" do
    all("tbody tr.clickable-remote-modal").first.all("td").first.click
    click_on "Rejeter"
    page.driver.browser.switch_to.alert.accept
    assert_selector "h4", "DEMANDES DE MISE À JOUR"
  end

end

