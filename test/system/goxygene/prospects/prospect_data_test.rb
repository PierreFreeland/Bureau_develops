require "application_system_test_case"
require "goxygene_set_up"

class ProspectDataTest < GoxygeneSetUp

  setup do
    visit goxygene.prospect_data_path(Goxygene::ProspectingDatum.find(5030))
  end

  test"should click submit" do
    visit goxygene.prospect_data_path(Goxygene::ProspectingDatum.find(5030))
    find(".btn.btn-orange.pull-right").click
    assert_selector "h4", "DONNÉES CONTACT"
  end

  test"Should show modal edit status" do
    find(".btn.btn-default.btn-xs.text-violet.text-bold")
    assert_selector "h4", "MODIFIER STATUT"
  end

  test"Should click call " do
    click_on  "Appel"
    assert_selector "h4", "NOUVELLE ACTION "
  end

  test"Should show C model" do
    click_on "C0"
    assert_selector "h4", "MODIFIER POTENTIEL"
  end

end
