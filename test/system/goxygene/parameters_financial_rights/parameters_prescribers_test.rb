require "application_system_test_case"
require "goxygene_set_up"

class ParametersPrescribersTest < GoxygeneSetUp
  setup do
    visit goxygene.prescribers_path
  end

  test "Should open a prescriber edit" do
    find('tr:first-child a[href*="/edit"]').click
    click_on "Enregistrer"
    assert_selector ".inscription-menus li.active a", text: "Droits financiers PL"
  end

  test "Should filter prescriber" do
    click_on "Filtres"
    find('#q_active_eq', visible: false).set(false)
    sleep 3
    assert_selector ".inscription-menus li.active a", text: "Droits financiers PL"
  end

  test "Should go to consultant page when click prescriber name" do
    find('tr:first-child a[href*="/consultants/"]').click
    assert_selector "li.active", text: "TIMELINE"
  end

  test "Should open a create modal" do
    click_on "Ajouter un prescripteur"
    sleep 3
    assert_selector "h4", text: "Ajouter un prescripteur"
  end
end
