require "application_system_test_case"
require "goxygene_set_up"

class ManagementsDessHistoriesTest < GoxygeneSetUp

  setup do
    visit goxygene.managements_dess_histories_path
    within '#des_year' do
      find("option[value='2020']").click
    end
    within '#des_itg_company_id' do
      find("option[value='1']").click
    end
    click_on "Actualiser"
  end

  test "Should export des excel on des history page" do
    click_on "Exporter"
    full_path = DOWNLOAD_PATH+"/export_dess.xlsx"
    sleep 2
    assert File.exist?(full_path)
  end

  test "Should open new tab after click download button" do
    page.all('tr')[2].click
    click_on "Télécharger"
    sleep 1
    window = page.driver.browser.window_handles
    assert window.size > 1
  end

  test "Should redirect to management dess histories detail" do
    page.all('tr')[2].click
    sleep 2
    assert_selector "h4", text: "DES INSTITUT DU TEMPS GÉRÉ"
  end

  test "Should export des excel on des history detail page" do
    page.all('tr')[2].click
    click_on "Exporter"
    full_path = DOWNLOAD_PATH+"/export_des.xlsx"
    assert File.exist?(full_path)
  end
end
