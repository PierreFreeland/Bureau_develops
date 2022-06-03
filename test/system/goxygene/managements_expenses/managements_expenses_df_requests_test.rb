require "application_system_test_case"
require "goxygene_set_up"

class ManagementsExpensesDfRequestsTest < GoxygeneSetUp

  setup do
    visit goxygene.managements_df_requests_path
  end

  test "Should update data on df request detail" do
    page.all('tr')[1].click
    fill_in "office_operating_expense[correspondent_comment]", with: "test comment"
    click_on "Enregistrer"
    assert_text("test comment")
  end

  test "Should not update data on df request detail" do
    page.all('tr')[1].click
    fill_in "office_operating_expense[correspondent_comment]", with: "test comment"
    accept_confirm do
      click_on "Annuler"
      sleep 4
    end
    assert_selector("#office_operating_expense_correspondent_comment", "")
  end

  test "Should export excel on das list page" do
    page.execute_script('$.find(".text-green")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH + "/managements_df_requests.xlsx"
    assert File.exist?(full_path)
  end

  test "Should redirect to managements expenses df request detail" do
    page.all('tr')[1].click
    assert_selector "h4", "Détail"
  end

  test "Should redirect to statement of operating expenses on consultant module after accept" do
    page.all('tr')[1].click
    accept_alert do
      click_on "Traiter la DF"
      sleep 2
    end
    assert_text "DÉPENSES DE FONCTIONNEMENT", wait: 2
  end

  test "Should redirect to df request list page after reject" do
    page.all('tr')[1].click
    accept_confirm do
      click_on "Renvoyer"
    end
    assert_selector( "h4", "DEMANDES DF", wait: 2)
  end

  test "Should delete first df request page after click Supprimer" do
    page.all('tr')[1].click
    accept_confirm do
      click_on "Supprimer"
    end
    sleep 2
    assert_equal page.all('tr').count, 1
  end
end
