require "application_system_test_case"
require "goxygene_set_up"

class ManagementsCesusTest < GoxygeneSetUp

  test "Should go to managements cesus info page when click Saisie" do
    visit goxygene.managements_cesus_path
    find('.pull-right ul.inscription-menus li.active a').click
    assert_selector ".inscription-menus li.active a", text: "Saisie"
  end

  test "Should go to managements cesus histories page when click Historique" do
    visit goxygene.managements_cesus_path
    click_on "Historique"
    assert_selector ".inscription-menus li.active a", text: "Historique"
  end

  test "Should go to managements cesu discounts page when click Remise CESU" do
    visit goxygene.managements_cesus_path
    click_on "Remise CESU"
    assert_selector ".inscription-menus li.active a", text: "Remise CESU"
  end
end
