require "application_system_test_case"
require "goxygene_set_up"
require 'api_accountancy'

class ParametersTest < GoxygeneSetUp

  test "Should redirect to parameters menu" do
    visit goxygene.parameters_path
    assert_selector "i.fa-cog"
  end

  test "Should redirect to management right from parameters menu" do
    visit goxygene.parameters_path
    click_on "Utilisateurs et groupes"
    assert_selector "h4", text: "UTILISATEURS ET GROUPES"
  end

  test "Should redirect to dsn dates from parameters menu" do
    visit goxygene.parameters_path
    click_on "Paramètres"
    assert_selector "h4", text: "DATES LIMITES DE DSN & DA"
  end

  test "Should redirect to financial rights from parameters menu" do
    visit goxygene.parameters_path
    click_on "Droits financiers"
    assert_selector "h4", text: "DROITS FINANCIERS PL"
  end

  test "Should redirect to devises from parameters menu" do
    visit goxygene.parameters_path
    click_on "Devises"
    assert_selector "h4", text: "DEVISES"
  end

  test "Should redirect to baremes from parameters menu" do
    visit goxygene.parameters_path
    click_on "Barèmes CV"
    assert_selector "h4", text: "TAUX DES CV"
  end

  test "Should redirect to itg group from parameters menu" do
    visit goxygene.parameters_path
    click_on "Groupe #{Goxygene::Parameter.value_for_group}"
    assert_selector "h4", text: "SOCIÉTÉS #{Goxygene::Parameter.value_for_group}"
  end

  test "Should redirect to bureau consultants from parameters menu" do
    visit goxygene.parameters_path
    click_on "Bureau"
    assert_selector "h4", text: "ARTICLES"
  end

  test "Should redirect to geographic from parameters menu" do
    visit goxygene.parameters_path
    click_on "Données géographiques"
    assert_selector "h4", text: "PAYS"
  end
end
