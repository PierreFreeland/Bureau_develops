require "application_system_test_case"
require "goxygene_set_up"

class ManagementsPeeDiscountsTest < GoxygeneSetUp
  test "Should sort asc Premier PEE when click Premier PEE" do
    visit goxygene.managements_pee_discounts_path
    click_on "Premier PEE"
    assert_selector ".sort_link.asc", text: "PREMIER PEE ▲"
  end

  test "Should sort asc Dernier PEE when click Dernier PEE" do
    visit goxygene.managements_pee_discounts_path
    click_on "Dernier PEE"
    assert_selector ".sort_link.asc", text: "DERNIER PEE ▲"
  end

  test "Should sort asc Société ITG when click Société ITG" do
    visit goxygene.managements_pee_discounts_path
    click_on "Société #{Goxygene::Parameter.value_for_group}"
    assert_selector ".sort_link.asc", text: "SOCIÉTÉ #{Goxygene::Parameter.value_for_group} ▲"
  end

  test "Should sort asc Imprimé le when click Imprimé le" do
    visit goxygene.managements_pee_discounts_path
    click_on "Imprimé le"
    assert_selector ".sort_link.asc", text: "IMPRIMÉ LE ▲"
  end

  test "Should sort asc Imprimé par when click Imprimé par" do
    visit goxygene.managements_pee_discounts_path
    click_on "Imprimé par"
    assert_selector ".sort_link.asc", text: "IMPRIMÉ PAR ▲"
  end
end
