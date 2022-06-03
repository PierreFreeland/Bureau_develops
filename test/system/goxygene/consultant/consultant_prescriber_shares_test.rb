require "application_system_test_case"
require "goxygene_set_up"

class ConsultantPrescriberSharesTest < GoxygeneSetUp

  setup do
    visit goxygene.consultant_prescriber_shares_path(Goxygene::Consultant.find(8786))
  end

  test "Should redirect to consultant prescriber share index" do
    assert_selector "h4", "DROITS FINANCIERS"
  end

  test "Should redirect to consultant timeline" do
    consultant = all("td a").first.text
    all("td a").first.click
    assert_selector "h4", consultant
  end

  test "Should filter by consultant name" do
    click_on "Filtres"
    find(".selection-counter").click
    sleep 1
    selected_consultant = all('.select2-results__option').last.text
    all('.select2-results__option').last.click
    click_on "Rechercher"
    sleep 1

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

  test "Should export excel" do
    page.execute_script('$.find(".fa-file-excel-o")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH+"/export.xlsx"
    assert File.exist?(full_path)
  end
end

