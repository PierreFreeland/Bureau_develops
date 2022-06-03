require "application_system_test_case"
require "goxygene_set_up"

class ClientsEstablishmentsTest < GoxygeneSetUp

  setup do
    visit goxygene.client_establishments_path(Goxygene::Customer.first)
  end

  test 'Should can filter' do
    click_on "Filtres"
    click_on "Rechercher"
    sleep 2
    assert_selector "li.active a", text:  "POINTS DE FACTURATION"
  end

  test "Should go to establishment timelines when click a one of list" do
    find('.list-table tbody tr:first-child td:first-child').click
    sleep 1
    assert_selector "li.active a", text: "TIMELINE"
    assert_selector "a.text-orange", text: "Établissements"
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
    sleep 2
    # assert_selector ".alert-danger li", text: "Raison sociale doit être rempli(e)"
    assert_selector ".alert-danger li", text: "Nom doit être rempli(e)"
    # assert_selector ".alert-danger li", text: "Le champ SIRET doit être renseigné ou le champ Personne physique doit être coché."
  end

  test "Should show a error message when fill a number in SIRET less than 14 characters" do
    click_on "Créer un Client Consultant"
    sleep 3
    fill_in "establishment[siret]", with: "0843980299777"
    click_on "Enregistrer"
    sleep 2
    assert_selector ".alert-danger li", text: "Le SIRET doit être composé de 14 chiffres."
  end

  test "Should show a error message when fill only a client name" do
    click_on "Créer un Client Consultant"
    sleep 3
    fill_in "establishment[name]", with: "01 Test"
    click_on "Enregistrer"
    sleep 2
    assert_selector ".alert-danger li", text: "Le SIRET doit être composé de 14 chiffres."
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

  test "export a excel" do
    page.execute_script('$.find(".text-green")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH + "/client_establishment.xlsx"
    assert File.exist?(full_path)
  end
end
