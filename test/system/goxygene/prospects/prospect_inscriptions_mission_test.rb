require "application_system_test_case"
require "goxygene_set_up"

class ProspectInscriptionsMissionTest < GoxygeneSetUp

  setup do
    visit goxygene.mission_prospect_inscriptions_path(Goxygene::ProspectingDatum.find(5030))
  end

  test"should click submit" do
    assert_selector "h4", "CONTRAT"
  end

  test"Should save" do
    click_on "Enregistrer"
    assert_selector "h4", " PREMIER CONTRAT"
  end

  test"Should show model Créer un Client Consultant and redirect to timeline"do
    find(".fa-plus").click
    sleep 1
    fill_in "establishment[name]", with: "test"
    fill_in "establishment[siret]", with: "88267908870686"
    sleep 1
    click_on "Enregistrer"
    assert_selector "h4", "TIMELINE"
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
