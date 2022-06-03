require "application_system_test_case"
require "goxygene_set_up"

class ManagementsExpensesDfsTest < GoxygeneSetUp

  setup do
    visit goxygene.managements_dfs_path
  end

  test "Should update data on df request detail" do
    page.all('tr')[1].click
    fill_in "operating_expense[correspondent_comment]", with: "test comment"
    click_on "Enregistrer"
    assert_text("test comment")
  end

  test "Should not update data on df request detail" do
    page.all('tr')[1].click
    fill_in "operating_expense[correspondent_comment]", with: "test comment"
    accept_confirm do
      click_on "Annuler"
      sleep 2
    end
    sleep 4
    assert_selector("#operating_expense_correspondent_comment", "")
  end

  test "Should export excel on dfs list page" do
    page.execute_script('$.find(".text-green")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH+"/managements_dfs.xlsx"
    assert File.exist?(full_path)
  end

  test "Should redirect to managements expenses dfs detail" do
    page.all('tr')[1].click
    assert_selector "h4", "Détail"
  end

  test "Should redirect to NDF on consultant after click Générer la NDF" do
    page.all('tr')[1].click
    click_on "Générer la NDF"
    assert_selector( "h4", "NDF", wait: 2)
  end

  test "Should redirect to dfs list page after click Refuser les frais" do
    page.all('tr')[1].click
    click_on "Refuser les frais"
    sleep 4
    assert_text("DF refusée")
  end
end
