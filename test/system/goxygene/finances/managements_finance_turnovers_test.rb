require "application_system_test_case"
require "goxygene_set_up"

class ManagementsFinanceTurnoversTest < GoxygeneSetUp

  test "Should show filter section" do
    visit goxygene.managements_finance_turnovers_path
    click_on "Filtres"
    assert_selector "label", "Année"
  end

  test "Should redirect to consultant page when click consultant in finances turnovers list" do
    visit goxygene.managements_finance_turnovers_path
    within ".clickable" do
      all('td')[3].click
    end
    assert_selector "h4", "LES INFOS CLÉS"
  end

end
