require "application_system_test_case"
require "goxygene_set_up"

class EstablishmentsTest < GoxygeneSetUp

  setup do
    visit goxygene.establishments_path
  end

  test "Should show result when filter" do
    fill_in "q[name_cont]", with: "LYANLA"
    click_on "Rechercher"
    sleep 1
    assert_selector "tbody tr:first-child td:nth-child(3)", text: "LYANLA"
  end

  test "Should go to establishment timeline when click a one of list" do
    find("tbody tr:first-child").click
    assert_selector "li.active a", text: "TIMELINE"
  end

  test "Should open a create modal" do
    click_on "Créer un Client Consultant"
    sleep 3
    assert_selector ".modal h4", text: "Créer un Client Consultant"
  end

  test "Should show a error messages" do
    click_on "Créer un Client Consultant"
    sleep 3
    click_on "Enregistrer"
    sleep 1
    assert_selector ".alert-danger li", text: "Raison sociale doit être rempli(e)"
    assert_selector ".alert-danger li", text: "Nom doit être rempli(e)"
    assert_selector ".alert-danger li", text: "Le champ SIRET doit être renseigné ou le champ Personne physique doit être coché."
  end

  test "Should show a error message when fill a number in SIRET less than 14 characters" do
    click_on "Créer un Client Consultant"
    sleep 3
    fill_in "establishment[siret]", with: "0843980299777"
    click_on "Enregistrer"
    sleep 1
    assert_selector ".alert-danger li", text: "Le SIRET doit être composé de 14 chiffres."
  end

  test "Should show a error message when fill only a client name" do
    click_on "Créer un Client Consultant"
    sleep 3
    fill_in "establishment[name]", with: "01 Test"
    click_on "Enregistrer"
    sleep 1
    assert_selector ".alert-danger li", text: "Le champ SIRET doit être renseigné ou le champ Personne physique doit être coché."
  end

  test "Should create a new client consultant" do
    click_on "Créer un Client Consultant"
    sleep 3
    fill_in "establishment[name]", with: "01 Test"
    fill_in "establishment[siret]", with: "08439802997777"
    click_on "Enregistrer"
    sleep 1
    assert_selector "li.active a", text: "TIMELINE"
    assert_selector "a.text-orange", text: "Établissements"
    assert_selector "a.text-orange", text: "01 Test"
  end
end
