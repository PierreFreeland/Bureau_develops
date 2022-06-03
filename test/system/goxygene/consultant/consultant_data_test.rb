require "application_system_test_case"
require "goxygene_set_up"

class ConsultantDataTest < GoxygeneSetUp

  setup do
    visit goxygene.consultant_data_path(Goxygene::Consultant.find(8786))
    assert_selector "li.active", text: "CONSULTANT"
  end

  test "Should be show a consultant data" do
    assert_selector "h4", text: "DONNÉES CONSULTANT"
    assert_selector "li.active", text: "Données de contact"
  end

  test "Should go to consultant competence page" do
    click_on "Compétences"
    assert_selector "li.active", text: "Compétences"
  end

  test "Should go to consultant socials page" do
    click_on "RH"
    assert_selector "li.active", text: "RH"
  end

  test "Should go to consultant insurance page" do
    click_on "Assurance"
    assert_selector "li.active", text: "Assurance"
  end

  test "Should go to consultant documents page" do
    click_on "Documents"
    assert_selector "li.active", text: "Documents"
  end

  test "Should go to consultant inscriptions page" do
    click_on "Dossier d'inscription"
    assert_selector "li.active", text: "Dossier d'inscription"
  end

  test "Should edit and save" do
    fill_in "consultant[nickname]", with: "Testing Nickname"
    select "Internet", from: "consultant[consultant_origin]"
    fill_in "consultant[contact_datum_attributes][email]", with: "testing@mail.com"
    fill_in "consultant[work_authorization_amount]", with: ""
    sleep 1
    fill_in "consultant[work_authorization_amount]", with: "100"
    select "Jours par an", from: "consultant[work_authorization_unit_id]"
    click_on 'Enregistrer'
    assert_input "#consultant_nickname", "Testing Nickname"
    assert_input "#consultant_contact_datum_attributes_email", "testing@mail.com"
    assert_input "#consultant_work_authorization_amount", 100.0
    assert_selector "#consultant_consultant_origin option[selected='selected']", text: "Internet"
    assert_selector "#consultant_work_authorization_unit_id option[selected='selected']", text: "Jours par an"
  end
end
