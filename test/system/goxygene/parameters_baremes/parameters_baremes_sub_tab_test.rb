require "application_system_test_case"
require "goxygene_set_up"

class ParametersBaremesSubTabTest < GoxygeneSetUp

  setup do
    visit goxygene.baremes_cvs_path
  end

  test "Should redirect to baremes cvs" do
    assert_selector "h4", "TAUX DES CV"
  end

  test "Should redirect to baremes categories" do
    within ".inscription-menus" do
      all('li')[0].click
    end
    assert_selector "h4", "BARÈMES CATÉGORIES"
  end

  test "Should redirect to baremes types" do
    within ".inscription-menus" do
      all('li')[1].click
    end
    assert_selector "h4", "BARÈMES TYPES"
  end

  test "Should redirect to baremes parameter cvs" do
    within ".inscription-menus" do
      all('li')[3].click
    end
    assert_selector "h4", "PARAMÈTRES CV"
  end
end
