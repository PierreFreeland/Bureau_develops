require "application_system_test_case"
require "goxygene_set_up"

class ParametersItgGroupSubTabTest < GoxygeneSetUp

  setup do
    visit goxygene.itg_society_index_path
  end

  test "Should redirect to itg society" do
    assert_selector "h4", "SOCIÉTÉS #{Goxygene::Parameter.value_for_group}"
  end

  test "Should redirect to itg establishment" do
    within ".inscription-menus" do
      all('li')[1].click
    end
    assert_selector "h4", "ETABLISSEMENTS #{Goxygene::Parameter.value_for_group}"
  end

  test "Should redirect to insurance companies" do
    within ".inscription-menus" do
      all('li')[2].click
    end
    assert_selector "h4", "COMPAGNIES D’ASSURANCE"
  end

  test "Should redirect to insurance contracts" do
    within ".inscription-menus" do
      all('li')[3].click
    end
    assert_selector "h4", "CONTRATS D’ASSURANCE"
  end

  test "Should redirect to insurance construction" do
    within ".inscription-menus" do
      all('li')[4].click
    end
    assert_selector "h4", "ASSURANCE CONSTRUCTION"
  end

  test "Should redirect to itg banks" do
    within ".inscription-menus" do
      all('li')[5].click
    end
    assert_selector "h4", "BANQUES #{Goxygene::Parameter.value_for_group}
  end

  test "Should redirect to itg bank agencies" do
    within ".inscription-menus" do
      all('li')[6].click
    end
    assert_selector "h4", "Agences bancaires"
  end
end
