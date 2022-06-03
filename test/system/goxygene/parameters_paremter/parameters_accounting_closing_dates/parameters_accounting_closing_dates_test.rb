require "application_system_test_case"
require "goxygene_set_up"

class ParametersAccountingClosingDatesTest < GoxygeneSetUp

  test "Should open a dsn date edit" do
    visit goxygene.dsn_dates_path
    find('tr:first-child a[href*="/edit"]').click
    click_on "Enregistrer"
    assert_selector ".inscription-menus li.active a", text: "Dates DSN & DA"
  end

  test "Should open a dsn date create form" do
    visit goxygene.dsn_dates_path
    click_on "Ajouter des nouvelles dates DSN & DA"

    click_on "Enregistrer"

    assert_selector ".inscription-menus li.active a", text: "Dates DSN & DA"
  end
end
