require "application_system_test_case"
require "goxygene_set_up"

class ManagementBankSlipsTest < GoxygeneSetUp

  test "Should show filter section" do
    visit goxygene.managements_bank_slips_path
    click_on "Filtres"
    assert_selector "label", "Dates"
  end

  test "Should redirect to new bank slip page" do
    visit goxygene.managements_bank_slips_path
    click_on "Créer un nouveau BRB"
    assert_selector "h4", "LA CRÉATION D’UN BORDEREAU DE REMISE EN BANQUE"
  end

  test "Should redirect to bank slip detail from bank slip page" do
    visit goxygene.managements_bank_slips_path
    page.all('tr')[1].click
    assert_selector ".control-label", text: "Numéro de bordereau"
  end

  test "Should export bank slips file" do
    visit goxygene.managements_bank_slips_path
    page.execute_script('$.find(".text-green")[0].click()')
    full_path = DOWNLOAD_PATH+"/managements_bank_slips.xlsx"
    assert File.exist?(full_path)
  end

end