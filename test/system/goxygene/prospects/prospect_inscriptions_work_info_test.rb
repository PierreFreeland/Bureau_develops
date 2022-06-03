require "application_system_test_case"
require "goxygene_set_up"

class ProspectInscriptionsWorkInfoTest < GoxygeneSetUp

  setup do
    visit goxygene.work_info_prospect_inscriptions_path(Goxygene::ProspectingDatum.find(5030))
  end

  test"should click submit" do
    assert_selector "h4", "SITUATION PROFESSIONNELLE"
  end

  test"Should save" do
    click_on "Enregistrer"
    assert_selector "h4", "DOSSIER D’INSCRIPTION"
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
