require "application_system_test_case"
require "goxygene_set_up"

class ConsultantDeclarationActivitiesTest < GoxygeneSetUp

  setup do
    visit goxygene.consultant_declaration_activities_path(Goxygene::Consultant.find(9392))
  end

  test "Should redirect to consultant declaration activities index" do
    assert_selector "h4", "DÉCLARATION D'ACTIVITÉS"
  end

  test "Should filter consultant declaration activities list" do
    click_on "Filtres"
    sleep 1
    execute_script("$('#q_month_and_year_gteq').val('1/2018')")
    execute_script("$('#q_month_and_year_lteq').val('12/2018')")
    click_on "Rechercher"
    sleep 1

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

  test "Should redirect to consultant declaration activities detail" do
    click_on "Filtres"
    sleep 1
    execute_script("$('#q_month_and_year_gteq').val('1/2018')")
    click_on "Rechercher"
    sleep 1

    all("tbody tr.clickable").first.click
    assert_selector "a", " Retour aux demandes de DA"
  end

  test "Should export excel" do
    click_on "Filtres"
    sleep 1
    execute_script("$('#q_month_and_year_gteq').val('1/2018')")
    click_on "Rechercher"
    sleep 1

    page.execute_script('$.find(".fa-file-excel-o")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH+"/consultant_declaration_activities.xlsx"
    assert File.exist?(full_path)
  end
end

