require "application_system_test_case"
require "goxygene_set_up"

class ManagementsDessTest < GoxygeneSetUp

  setup do
    visit goxygene.new_managements_dess_path
    within '#des_year' do
      find("option[value='2019']").click
    end
    within '#des_month' do
      find("option[value='11']").click
    end
    within '#des_itg_company_id' do
      find("option[value='20']").click
    end
    click_on "Actualiser"
  end

  test "Should found list of data after filter" do
    # Included table head
    assert page.all('table.list-table tr').count > 1
  end

  test "Should redirect to history after validate" do
    click_on "Valider"
    assert_selector "h4", "DES SNPS PORTEO"
  end

  test "Should export des excel on des page" do
    click_on "Exporter"
    full_path = DOWNLOAD_PATH+"/export_des.xlsx"
    assert File.exist?(full_path)
  end

end
