require "application_system_test_case"
require "goxygene_set_up"

class EstablishmentDataTest < GoxygeneSetUp

  test "Should show a error message when SIREN and SIRET do not match" do
    visit goxygene.establishment_data_path(Goxygene::Establishment.find(12517))
    sleep 1
    fill_in "establishment_siret", with: "11139817526547"
    click_on "Enregistrer"
    sleep 2
    assert_selector ".alert-danger li", text: "Les numéros de SIRET et SIREN ne correspondent pas. Merci de vérifier le numéro de SIRET"
  end

  test "Should show a error message when fill a number of SIRET less than 14 characters" do
    visit goxygene.establishment_data_path(Goxygene::Establishment.find(12517))
    sleep 1
    fill_in "establishment_siret", with: "51817284611"
    click_on "Enregistrer"
    sleep 2
    assert_selector ".alert-danger li", text: "Le SIRET doit être composé de 14 chiffres."
    assert_selector ".alert-danger li", text: "Le SIRET n'est pas valide"
  end

  test "Should show a error message when not fill in SIRET" do
    visit goxygene.establishment_data_path(Goxygene::Establishment.find(12517))
    sleep 1
    fill_in "establishment_siret", with: ""
    click_on "Enregistrer"
    sleep 2
    assert_selector ".alert-danger li", text: "Le champ SIRET doit être renseigné ou le champ Personne physique doit être coché."
  end
end
