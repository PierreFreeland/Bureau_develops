require "application_system_test_case"
require "goxygene_set_up"

class ClientConsultantsTest < GoxygeneSetUp

  setup do
    visit goxygene.client_consultants_path(Goxygene::Customer.last)
    assert_selector 'h4', text: 'CONSULTANTS AYANT FACTURE'
  end

  test "Should redirect to consultant timelines" do
    text = all('tr')[2].all('td')[2].text
    all('tr')[2].click
    assert_selector "a", text: text
    assert_selector "h4", text: "TIMELINE"
  end

  test "Should export excel" do
    page.execute_script('$.find(".text-green")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH+"/client_consultant_bill.xlsx"
    assert File.exist?(full_path)
  end
end