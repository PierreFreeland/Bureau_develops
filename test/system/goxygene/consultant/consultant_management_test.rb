require "application_system_test_case"
require "goxygene_set_up"

class ConsultantManagementTest < GoxygeneSetUp
  setup do
    visit goxygene.consultant_management_path(Goxygene::Consultant.find(8786))
    assert_selector "h4", text: "GESTION CONSULTANT"
  end

  test "Should update data" do
    find("#consultant_activity_report", visible: false).set(true)
    find("#consultant_full_wage_advance", visible: false).set(true)
    find("#consultant_cas_authentication_attributes_active", visible: false).set(true)
    fill_in "consultant[expected_fees]", with: "1"
    fill_in "consultant[expected_fees_corrected_amount]", with: "1"
    fill_in "consultant[vehicle_attributes][entry_into_service]", with: "#{Date.today.strftime("%d/%m/%Y")}"
    fill_in "consultant[vehicle_attributes][co2_emissions]", with: "120"

    click_on "Enregistrer"
    sleep 1

    page.has_checked_field?('consultant_activity_report')
    page.has_checked_field?('consultant_full_wage_advance')
    page.has_checked_field?('consultant_cas_authentication_attributes_active')
    assert_selector "#consultant_expected_fees[value='1.0']"
    assert_selector "#consultant_expected_fees_corrected_amount[value='1.0']"
    assert_selector "#consultant_vehicle_attributes_entry_into_service[value='#{Date.today.strftime("%d/%m/%Y")}']"
    assert_selector "#consultant_vehicle_attributes_co2_emissions[value='120']"
  end

  test "Should show error when fill vehicle" do
    fill_in "consultant[vehicle_attributes][entry_into_service]", with: "#{Date.today.strftime("%d/%m/%Y")}"
    click_on "Enregistrer"
    sleep 1
    assert_selector '.alert-danger li', text: "Émission CO2 doit être rempli(e)"
  end
end