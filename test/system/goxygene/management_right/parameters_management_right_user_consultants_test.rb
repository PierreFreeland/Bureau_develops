require "application_system_test_case"
require "goxygene_set_up"
require 'api_accountancy'

class ParametersManagementRightUserConsultantsTest < GoxygeneSetUp

  setup do
    visit goxygene.user_consultants_path
  end

  test "Should redirect to user consultants page" do
    page.all('li')[9].click
    page.all('li')[9].has_css?('.active')
  end

  test "Should sort asc Email when click Email" do
    click_on "Email"
    assert_selector ".sort_link.asc", text: "EMAIL ▲"
  end

  test "Should can filter" do
    find('#q_consultant_radio_1').set(true)
    click_on "Rechercher"
    sleep 2
    assert_selector "#consultant-user-table tbody tr:first-child"
  end

  test "Should can update a consultant" do
    Goxygene::EmployeeRolesEmployee.create(employee_id: 53, employee_role_id: 2)

    find('#q_consultant_radio_1').set(true)
    click_on "Rechercher"
    sleep 2
    select "#{Goxygene::Parameter.value_for_group} Admin", from: "correspondant_employee_id"
    click_on "Réaffecter les consultants"
    sleep 3
    assert_text "Les modifications ont bien été enregistrées."
  end
end
