require "application_system_test_case"
require "goxygene_set_up"

class EstablishmentContactManagementsTest < GoxygeneSetUp
  setup do
    visit goxygene.establishment_contact_managements_path(Goxygene::Establishment.last)
    assert_selector "h4", text: "FICHES CONTACTS"
  end

  test "Should filter contact with name" do
    name = all('tr.clickable')[0].all('td')[2].text

    fill_in "q[contact_datum_email_cont]", with: name
    click_on 'Rechercher'
    sleep 2

    assert_selector "td", text: name
  end

  test "Should create" do
    find("i.fa-plus").click
    sleep 1
    assert_selector "label", text: "Nom"

    find('.contact-department-selection').find(:xpath, 'option[2]').select_option
    sleep 1
    find('.contact-role-selection').find(:xpath, 'option[2]').select_option
    sleep 1
    click_on "Enregistrer"

    assert_selector 'li',text: "Le champ SIRET doit être renseigné ou le champ Personne physique doit être coché."
    # assert_selector 'tr.fields td',text: "#{Goxygene::ContactRole.find(3).label}"
    # assert_selector 'tr.fields td',text: "#{Goxygene::ContactDepartment.find(2).label}"
  end

  test "Should change contact principal" do
    all(".nested-form-radio").first.click
    click_on "Enregistrer"
    assert_selector 'input.nested-form-radio[checked=checked]'
  end

  test "Should delete contact" do
    before = page.all('tr').count
    execute_script("$('.fa-minus-square')[0].click()")
    sleep 2
    assert_equal before-1, page.all('tr').count
  end

  test "Should redirect and update company contact" do
    all('tr.clickable').last.click
    sleep 2
    assert_selector 'h4',text: 'HONIGMAN PHILIPPE'

    fill_in "establishment_contact[contact_datum_attributes][mobile_phone]", with: "09999999"
    fill_in "establishment_contact[contact_datum_attributes][email]", with: "test@mail.com"

    click_on "Enregistrer"

    assert_selector "input#establishment_contact_contact_datum_attributes_mobile_phone[value='09999999']"
    assert_selector "input#establishment_contact_contact_datum_attributes_email[value='test@mail.com']"
  end
end