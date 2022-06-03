require "application_system_test_case"
require "goxygene_set_up"

class ConsultantRegistersTest < GoxygeneSetUp
  setup do
    visit goxygene.consultant_registers_path
    assert_selector "h4", text: "RH"
  end

  test "Should create new consultant" do
    click_on "Créer un consultant"
    select "Madame", from: "consultant[individual_attributes][civility_id]"
    fill_in "consultant[individual_attributes][last_name]", with: "username"
    fill_in "consultant[individual_attributes][first_name]", with: "name"
    fill_in "consultant[contact_datum_attributes][email]", with: "test@mail.com"
    select "#{Goxygene::Parameter.value_for_group} CONSEIL", from: "consultant[itg_establishment_id]"

    find('#select2-consultant_consultant_accountancy_data_attributes_0_accountancy_consultant_group_id-container').click
    sleep 1
    find(:css, "input[class$='select2-search__field']").set("ac")
    sleep 1
    find('ul:first-child li:first-child[role*="treeitem"]').click
    sleep 1
    select "Madame Caroline LEONARD", from: "consultant[correspondant_employee_id]"
    select "Madame Caroline LEONARD", from: "consultant[advisor_employee_id]"
    fill_in "consultant[itg_margin]", with: "7"
    sleep 1
    click_on "Valider"

    assert_selector "h4", text: "TIMELINE"
  end

  test "Should redirect to index" do
    click_on "Créer un consultant"
    click_on "Annuler"

    assert_selector "h4", text: "RH"
  end
end

