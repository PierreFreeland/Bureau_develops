require "application_system_test_case"
require "goxygene_set_up"

class ParametersPrescriberHistoriesTest < GoxygeneSetUp

  setup do
    visit goxygene.prescriber_histories_path
  end

  test "Should filter with month and year" do
    fill_in 'q[month]', with: "12"
    fill_in 'q[year]', with: "2020"
    click_on 'Rechercher'
    assert_selector ".inscription-menus li.active a", text: "Historique des droits PL"
  end
end
