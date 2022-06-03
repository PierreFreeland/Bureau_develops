require "application_system_test_case"
require "goxygene_set_up"

class ConsultantPrescribersTest < GoxygeneSetUp

  setup do
    visit goxygene.consultant_prescribers_path(Goxygene::Consultant.find(8786))
  end

  test "Should redirect to consultant prescriber index" do
    assert_selector "h4", "AYANT DROITS"
  end

  test "Should redirect to consultant timeline" do
    consultant =  all('td a').first.text
    all('td a').first.click
    assert_selector "h4", consultant
  end

  test "Should filter by consultant name" do
    click_on "Filtres"
    find(".selection-counter").click
    sleep 1
    selected_consultant = all('.select2-results__option').last.text
    all('.select2-results__option').last.click
    click_on "Rechercher"

    result = []
    all('td a').each do |consultant|
      if selected_consultant.include?(consultant.text)
        result << true
      else
        result << false
      end
    end
    assert !result.include?(false)
  end

  test "Should filter by consultant status inactive" do
    click_on "Filtres"
    execute_script("$('input#q_consultant_status_eq').click()")
    click_on "Rechercher"

    result = []
    all('.list-table tbody tr').each do |list|
      if list.all("td").last.text == "Inactif"
        result << true
      else
        result << false
      end
    end
    assert !result.include?(false)
  end

  test "Should export excel" do
    page.execute_script('$.find(".fa-file-excel-o")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH+"/export.xlsx"
    assert File.exist?(full_path)
  end
end

