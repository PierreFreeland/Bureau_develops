require "application_system_test_case"
require "goxygene_set_up"

class ClientContactManagementsTest < GoxygeneSetUp

  setup do
    visit goxygene.client_contact_managements_path(Goxygene::Customer.last)
  end

  test "Should show error when create" do
    find("i.fa-plus").click
    sleep 1
    assert_selector "label", text: "Nom"

    click_on "Enregistrer"

    assert_selector '.alert-danger li', text: "La fonction du contact doit être précisée"
    assert_selector '.alert-danger li', text: "Le département du contact doit être précisé"
  end

  test "Should create" do
    find("i.fa-plus").click
    sleep 1
    assert_selector "label", "Nom"

    find('.contact-department-selection').find(:xpath, 'option[2]').select_option
    sleep 1
    find('.contact-role-selection').find(:xpath, 'option[2]').select_option
    sleep 1
    click_on "Enregistrer"

    assert_selector 'tr.fields td', text: "#{Goxygene::ContactRole.find(3).label}"
    assert_selector 'tr.fields td', text: "#{Goxygene::ContactDepartment.find(2).label}"
  end

  test "Should change contact principal" do
    all(".nested-form-radio").first.click

    page.driver.browser.switch_to.alert.accept
    sleep 1

    click_on "Enregistrer"
    assert_selector 'input.nested-form-radio[checked=checked]'
  end

  test "Should delete contact" do
    before = page.all('tr').count
    execute_script("$('.fa-minus')[0].click()")
    sleep 2
    assert_equal before-1, page.all('tr').count
  end

  test "Should redirect and update company contact" do
    all('tr')[1].click
    assert_selector 'h4', text: 'CONTACT'

    fill_in "company_contact[individual_attributes][last_name]", with: "last name"
    fill_in "company_contact[individual_attributes][first_name]", with: "first name"
    fill_in "company_contact[contact_datum_attributes][phone]", with: "09999999"
    fill_in "company_contact[contact_datum_attributes][email]", with: "test@mail.com"

    click_on "Enregistrer"

    assert_selector "input#company_contact_individual_attributes_last_name[value='last name']"
    assert_selector "input#company_contact_individual_attributes_first_name[value='first name']"
    assert_selector "input#company_contact_contact_datum_attributes_phone[value='09999999']"
    assert_selector "input#company_contact_contact_datum_attributes_email[value='test@mail.com']"
  end
end