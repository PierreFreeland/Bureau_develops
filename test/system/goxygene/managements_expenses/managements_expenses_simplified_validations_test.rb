require "application_system_test_case"
require "goxygene_set_up"

class ManagementsExpensesSimplifiedValidationsTest < GoxygeneSetUp

  setup do
    visit goxygene.managements_simplified_validations_path
  end

  test "Should export excel on simplified validations list page" do
    page.execute_script('$.find(".text-green")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH+"/managements_simplified_validations.xlsx"
    assert File.exist?(full_path)
  end

  test "Should redirect to managements expenses simplified validations detail" do
    page.all('tr')[1].click
    assert_selector "h4", "Détail"
  end

  test "Should redirect to simplified validations list page after click on OK" do
    page.all('tr')[1].click
    click_on "OK"
    sleep 3
    assert_selector("h4", "VALIDATION SIMPLIFIÉE DES FRAIS", wait: 2)
  end

end
