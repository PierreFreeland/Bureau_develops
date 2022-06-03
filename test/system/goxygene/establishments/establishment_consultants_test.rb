require "application_system_test_case"
require "goxygene_set_up"

class EstablishmentConsultantsTest < GoxygeneSetUp

  setup do
    visit goxygene.establishment_consultants_path(Goxygene::Establishment.last)
  end

  test "Should redirect to establishment consultants page" do
    assert_selector "h4", "CONSULTANTS"
  end

  test "Should redirect to consultant detail from establishment consultants" do
    list = page.all("tbody a")
    if list.count > 0
      consultant = list.first.text
      list.first.click
      assert_selector "h4", consultant
    end
  end

  test "Should export excel" do
    page.execute_script('$.find(".text-green")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH+"/establishment_consultant_bill.xlsx"
    assert File.exist?(full_path)
  end
end
