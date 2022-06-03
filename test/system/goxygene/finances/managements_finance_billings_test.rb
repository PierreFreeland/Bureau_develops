require "application_system_test_case"
require "goxygene_set_up"

class ManagementsFinanceBillingsTest < GoxygeneSetUp

  test "Should show filter section" do
    visit goxygene.managements_finance_billings_path
    click_on "Filtres"
    assert_selector "label", "Année"
  end

  test "Should redirect to consultant page" do
    visit goxygene.managements_finance_billings_path
    within ".clickable" do
      all('td')[3].click
    end
    assert_selector "h4", "LES INFOS CLÉS"
  end

end
