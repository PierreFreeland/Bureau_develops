require "application_system_test_case"
require "goxygene_set_up"

class ConsultantsDeclarationActivitiesTest < GoxygeneSetUp

  setup do
    visit goxygene.consultants_declaration_activities_path
  end

  test 'Should open detail page' do
    all("tbody tr.clickable").first.all("td").first.click
    assert_selector "h4", text: "DEMANDES DE DA"
  end

  test "Should filter consultant declaration activities list" do
    find(".fa-arrow-right").click
    click_on "Filtres"
    sleep 1
    execute_script("$('#q_consultant_validation_gteq').val('1/2018')")
    execute_script("$('#q_consultant_validation_lteq').val('12/2018')")
    click_on "Rechercher"

    check = []
    all("tbody tr.clickable").each do |tr|
      if "2018".in?(tr.all("td")[0].text)
        check << true
      else
        check << false
      end
    end
    assert !check.include?(false)
  end

  test "Click check button" do
    find(".fa-arrow-right").click
    all("tbody tr.clickable").first.all("td").first.hover
    find(".fa-check").click
    page.driver.browser.switch_to.alert.accept
    sleep 1
    assert_selector "h4", "DÉCLARATION D'ACTIVITÉS"
  end

  test "Click arrow right" do
    find(".fa-arrow-right").click
    all("tbody tr.clickable").first.all("td").first.hover
    find('tbody tr:first-child a[data-confirm="Le statut changera à demande traitée"]').click
    page.driver.browser.switch_to.alert.accept
    assert_selector "h4", "DÉCLARATION D'ACTIVITÉS"
  end

  test "Click undo" do
    all("tbody tr.clickable").first.all("td").first.hover
    find(".fa-undo").click
    page.driver.browser.switch_to.alert.accept
    assert_selector "h4", "DEMANDES DE DA"
  end

  test "Click fa-ban" do
    all("tbody tr.clickable").first.all("td").first.hover
    find(".fa-ban").click
    page.driver.browser.switch_to.alert.accept
    assert_selector "h4", "DÉCLARATION D'ACTIVITÉS"
  end

  test "detail page" do
    all("tbody tr.clickable").first.all("td").first.click

    execute_script("$('.fa-file-pdf-o')[0].click()")
    sleep 2
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert has_selector? 'embed[type="application/pdf"]'
  end

  test "detail page click on Générer le salaire "do
    all("tbody tr.clickable").first.all("td").first.click
    click_on 'Générer le salaire'
    page.driver.browser.switch_to.alert.accept
    assert_selector 'a','Le statut changera à demande validée'
  end

  test "detail page click on Traiter la DA "do
    all("tbody tr.clickable").first.all("td").first.click
    click_on 'Traiter la DA'
    page.driver.browser.switch_to.alert.accept
    assert_selector 'a','Le statut changera à demande traitée'
  end

  test "detail page click on Renvoyer "do
    all("tbody tr.clickable").first.all("td").first.click
    click_on 'Renvoyer'
    page.driver.browser.switch_to.alert.accept
    assert_selector 'a','Le statut changera à demande renvoyée'
  end

end
