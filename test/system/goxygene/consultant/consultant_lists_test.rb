require "application_system_test_case"
require "goxygene_set_up"

class ConsultantListsTest < GoxygeneSetUp
  setup do
    visit goxygene.consultant_lists_path
  end

  test "Should redirect to consultant list index page" do
    assert_selector "h4", "CONSULTANTS"
  end

  test "Should redirect to consultant details page" do
    all('tbody tr').first.click
    assert_selector "h4", "TIMELINE"
  end

  test "Should export excel" do
    page.execute_script('$.find(".fa-file-excel-o")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH+"/consultant_lists.xlsx"
    assert File.exist?(full_path)
  end

  test "Should list consultant has active contract" do
    select "Contrat de travail validés", from: "q_has_active_contract_eq"
    sleep 2
    assert_equal all('fa-times-circle-o').size, 0
  end

  test "Should list consultant has no active contract" do
    select "Contrat de travail validés", from: "q_has_active_contract_eq"
    sleep 2
    assert_equal all('fa-check-circle-o').size, 0
  end

  test "Should filter by consultant last name" do
    fill_in "q_individual_last_name_cont", with: "Grant"
    sleep 2
    assert_equal all('tbody tr').size, 1
  end

  test "Should filter by consultant birth name" do
    fill_in "q_individual_birth_name_cont", with: "Grant"
    sleep 2
    assert_equal all('tbody tr').size, 1
  end

  test "Should filter by consultant first name" do
    fill_in "q_individual_first_name_cont", with: "Kurtis"
    sleep 2
    assert_equal all('tbody tr').size, 1
  end

  test "Should filter by consultant email" do
    fill_in "q_contact_datum_email_cont", with: "Kurtis.Grant_10042@consulting-itg.fr"
    sleep 2
    assert_equal all('tbody tr').size, 1
  end

  test "Should filter by consultant mobile phone" do
    fill_in "q_contact_datum_mobile_phone_cont", with: "3650091152"
    sleep 2
    assert_equal all('tbody tr').size, 1
  end

  test "Should filter by consultant payroll code" do
    find('#q_consultant_accountancy_data_payroll_code_cont').set("9392\n")
    sleep 2
    assert_equal all('tbody tr').size, 1
  end

  test "Should filter by itg establishment" do
    select "#{Goxygene::Parameter.value_for_group} CONSEIL", from: "q_itg_establishment_id_in"
    sleep 2
    check = []
    all("tbody tr").each do |tr|
      if tr.all("td")[2].text == "#{Goxygene::Parameter.value_for_group} CONSEIL"
        check << true
      else
        check << false
      end
    end
    assert !check.include?(false)
  end

  test "Should filer by consultant competences" do
    find('#q_competences_cont').set("Conseil\n")
    sleep 2
    check = []
    all("tbody tr").each do |tr|
      if tr.all("td")[10].text.include?("Conseil")
        check << true
      else
        check << false
      end
    end
    assert !check.include?(false)
  end
end

