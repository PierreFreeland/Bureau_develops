require "application_system_test_case"
require "goxygene_set_up"

class ManagementsPeesTest < GoxygeneSetUp

  test "Should go to managements pee info page when click Saisie" do
    visit goxygene.managements_pees_path
    click_on "Saisie"
    assert_selector ".inscription-menus li.active a", text: "Saisie"
  end

  test "Should go to managements pee histories page when click Historique" do
    visit goxygene.managements_pees_path
    click_on "Historique"
    assert_selector ".inscription-menus li.active a", text: "Historique"
  end

  test "Should go to managements pee discounts page when click Remise PEE" do
    visit goxygene.managements_pees_path
    click_on "Remise PEE"
    assert_selector ".inscription-menus li.active a", text: "Remise PEE"
  end
end
