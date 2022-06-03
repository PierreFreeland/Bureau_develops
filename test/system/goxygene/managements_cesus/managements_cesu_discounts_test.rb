require "application_system_test_case"
require "goxygene_set_up"

class ManagementsCesuDiscountsTest < GoxygeneSetUp

  test "Should sort asc Premier CESU when click Premier CESU" do
    visit goxygene.managements_cesu_discounts_path
    click_on "Premier CESU"
    assert_selector ".sort_link.asc", text: "PREMIER CESU ▲"
  end

  test "Should sort asc Dernier CESU when click Dernier CESU" do
    visit goxygene.managements_cesu_discounts_path
    click_on "Dernier CESU"
    assert_selector ".sort_link.asc", text: "DERNIER CESU ▲"
  end

  test "Should sort asc Société ITG when click Société ITG" do
    visit goxygene.managements_cesu_discounts_path
    click_on "Société #{Goxygene::Parameter.value_for_group}"
    assert_selector ".sort_link.asc", text: "SOCIÉTÉ #{Goxygene::Parameter.value_for_group} ▲"
  end

  test "Should sort asc Imprimé le when click Imprimé le" do
    visit goxygene.managements_cesu_discounts_path
    click_on "Imprimé le"
    assert_selector ".sort_link.asc", text: "IMPRIMÉ LE ▲"
  end

  test "Should sort asc Imprimé par when click Imprimé par" do
    visit goxygene.managements_cesu_discounts_path
    click_on "Imprimé par"
    assert_selector ".sort_link.asc", text: "IMPRIMÉ PAR ▲"
  end
end
