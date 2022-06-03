require "application_system_test_case"
require "goxygene_set_up"

class ConsultantSignaturesTest < GoxygeneSetUp
  setup do
    visit goxygene.consultant_signatures_path
    assert_selector "h4", text: "EN ATTENTE DE SIGNATURE"
  end

  test "Should filters by status" do
    click_on "Filtres"

    select "Attente de signature manuelle", from: "q[status_eq]"
    sleep 2

    result = []
    all(".list-table tbody tr").each do |tr|
      if ('Attente de signature manuelle').include?(tr.all("td")[8].text)
        result << true
      else
        result << false
      end
    end
    assert !result.include?(false)
  end

  test "Should redirect to contract detail" do
    page.all('tr')[1].click
    sleep 1
    assert_selector "h4", text: "DÉTAIL DU CONTRAT"
  end

  test "excel export" do
    page.execute_script('$.find(".text-green")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH+"/consultant_signature.xlsx"
    assert File.exist?(full_path)
  end
end

