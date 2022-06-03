require "application_system_test_case"
require "goxygene_set_up"

class ParametersParameterTest < GoxygeneSetUp

  test "Should go to dsn dates info page when click Dates DSN & DA" do
    visit goxygene.dsn_dates_path
    find('.pull-right ul.inscription-menus li.active a').click
    assert_selector ".inscription-menus li.active a", text: "Dates DSN & DA"
  end

  test "Should go to accounting closing dates info page when click Dates clôture comptable" do
    visit goxygene.dsn_dates_path
    click_on "Dates clôture comptable"
    assert_selector ".inscription-menus li.active a", text: "Dates clôture comptable"
  end

  test "Should go to pee parameters info page when click Paramètres PEE" do
    visit goxygene.dsn_dates_path
    click_on "Paramètres PEE"
    assert_selector ".inscription-menus li.active a", text: "Paramètres PEE"
  end

  test "Should go to cesu parameters info page when click Paramètres CESU" do
    visit goxygene.dsn_dates_path
    click_on "Paramètres CESU"
    assert_selector ".inscription-menus li.active a", text: "Paramètres CESU"
  end

  test "Should go to other parameters info page when click Autres paramètres" do
    visit goxygene.dsn_dates_path
    click_on "Autres paramètres"
    assert_selector ".inscription-menus li.active a", text: "Autres paramètres"
  end
end
