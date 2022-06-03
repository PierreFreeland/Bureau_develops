require "application_system_test_case"
require "goxygene_set_up"

class ProspectInscriptionsPersonalInfoTest < GoxygeneSetUp

  setup do
    visit goxygene.personal_info_prospect_inscriptions_path(Goxygene::ProspectingDatum.find(5030))
  end

  test"should click submit" do
    assert_selector "h4", "CONTRAT"
  end

  test"Should save" do
    fill_in "prospecting_datum[consultant_attributes][bank_account_attributes][iban]", with: "FR7618206004203546255700114"
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
