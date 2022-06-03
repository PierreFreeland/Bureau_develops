require "application_system_test_case"
require "goxygene_set_up"

class ParametersDsnDatesTest < GoxygeneSetUp

  test "Should open a accounting closing dates edit" do
    visit goxygene.accounting_closing_dates_path
    find('tr:first-child a[href*="/edit"]').click
    click_on "Enregistrer"
    assert_selector ".inscription-menus li.active a", text: "Dates clôture comptable"
  end

  test "Should open a accounting closing dates create form" do
    visit goxygene.accounting_closing_dates_path
    click_on "Ajouter une date de clôture comptable"

    click_on "Enregistrer"

    assert_selector ".inscription-menus li.active a", text: "Dates clôture comptable"
  end
end
