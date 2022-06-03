require "application_system_test_case"
require "goxygene_set_up"

class ManagementsDessSubTabTest < GoxygeneSetUp

  test "Should go to managements dess new page when click Déclaration" do
    visit goxygene.new_managements_dess_path
    click_on "Déclaration"
    assert_selector ".inscription-menus li.active a", text: "Déclaration"
  end

  test "Should go to managements dess histories page when click Historique" do
    visit goxygene.new_managements_dess_path
    click_on "Historique"
    assert_selector ".inscription-menus li.active a", text: "Historique"
  end
end
