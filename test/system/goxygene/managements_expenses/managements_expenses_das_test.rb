require "application_system_test_case"
require "goxygene_set_up"

class ManagementsExpensesDasTest < GoxygeneSetUp

  setup do
    visit goxygene.managements_expenses_path
  end

  test "Should export excel on das list page" do
    page.execute_script('$.find(".text-green")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH+"/expense_das.xlsx"
    assert File.exist?(full_path)
  end

  test "Should redirect to managements expenses da detail" do
    page.all('tr')[1].click
    assert_selector "h4", "Détail"
  end

  # test "Change ITG" do
  #   page.all('tr')[1].click
  #   assert_equal "En attente de traitement"
  # end

  test "Should redirect to consultant module after click on Accepter frais en attente" do
    page.all('tr')[1].click
    click_on "Accepter frais en attente"
    sleep 3
    assert_selector("li.currentPage a[href='#consultantMenu']", "Consultant")
  end

  test "Should redirect to consultant module after click on Accepter frais en BAP" do
    page.all('tr')[1].click
    click_on "Accepter frais en BAP"
    sleep 3
    assert_selector("li.currentPage a[href='#consultantMenu']", "Consultant")
  end

  test "Should change status to rejected after click on Refuser les frais" do
    page.all('tr')[1].click
    click_on "Refuser les frais"
    assert_text("Annulés", wait: 2)
  end

  test "Should open pdf on new tab after click pdf icon" do
    page.all('tr')[1].click
    execute_script("$('.fa-file-pdf-o').click()")
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert window.size > 1
  end

  test "Should update data on da detail" do
    page.all('tr')[1].click
    fill_in "activity_report[correspondent_comment]", with: "test comment"
    click_on "Enregistrer"
    assert_text("test comment")
  end

  test "Should not update data on da detail" do
    page.all('tr')[1].click
    fill_in "activity_report[correspondent_comment]", with: "test comment"
    accept_alert do
      click_on "Annuler"
    end
    assert_selector("#activity_report_correspondent_comment", "")
  end
end
