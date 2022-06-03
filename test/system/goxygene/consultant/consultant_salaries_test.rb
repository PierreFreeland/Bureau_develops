require "application_system_test_case"
require "goxygene_set_up"

class ConsultantSalariesTest < GoxygeneSetUp

  setup do
    visit goxygene.consultant_salaries_path(Goxygene::Consultant.find(9392))
  end

  test "Should redirect to consultant salaries index" do
    assert_selector "h4", "SALAIRES"
  end

  test "Should create new consultant salaries" do
    before = all(".list-table tbody tr").size

    click_on "Créer un salaire"
    sleep 1
    execute_script("$('#wage_month_and_year').val('#{Date.today.strftime("%m/%Y")}')")
    fill_in "wage_hours", with: 1000
    fill_in "wage_comment", with: "Test"
    accept_alert do
      all("input[value='Enregistrer']").first.click
    end
    sleep 1

    assert_equal before + 1, all(".list-table tbody tr").size
  end

  test "Should download payslip" do
    click_on "Filtres"
    sleep 1
    execute_script("$('#q_period_start_gteq').val('01/01/2018')")
    click_on "Rechercher"
    sleep 1

    execute_script('$("a[data-title=\"Bulletin de salaire\"]")[0].click()')
    sleep 2
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert window.size > 1
  end

  test "Should redirect to DA detail" do
    click_on "Filtres"
    sleep 1
    execute_script("$('#q_period_start_gteq').val('01/01/2018')")
    click_on "Rechercher"
    sleep 1

    execute_script('$("a[data-title=\"Voir DA\"]")[0].click()')
    sleep 2
    assert_selector "h4", "DÉCLARATION D'ACTIVITÉS"
  end

  test "Should delete 1 of consultant salary" do
    click_on "Filtres"
    sleep 1
    execute_script("$('#q_period_start_gteq').val('01/01/2018')")
    click_on "Rechercher"
    sleep 1

    before =  all("tr.text-red").size
    accept_alert do
      execute_script('$("a[data-title=\"Supprimer ce salaire\"]")[0].click()')
    end
    sleep 1
    assert_equal before - 1, all("tr.text-red").size
  end

  test "Should export excel" do
    page.execute_script('$.find(".fa-file-excel-o")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH+"/consultants_salaries.xlsx"
    assert File.exist?(full_path)
  end
end

