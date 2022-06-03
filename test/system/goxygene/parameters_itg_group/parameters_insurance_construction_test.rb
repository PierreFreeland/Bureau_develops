require "application_system_test_case"
require "goxygene_set_up"

class ParametersInsuranceConstructionTest < GoxygeneSetUp

  setup do
    visit goxygene.insurance_construction_index_path
  end

  test "Should open create insurance construction modal" do
    click_on "Créer une assurance construction"
    assert_selector "h4", "Ajout d’une assurance construction"
  end

  test "Should create new insurance construction" do
    before = page.all('tr').count
    click_on "Créer une assurance construction"
    fill_in "construction_insurance_rate_accountancy_code", with: "TEST"
    fill_in "construction_insurance_rate_label", with: "test"
    fill_in "construction_insurance_rate_rate", with: "5"
    click_on "Enregistrer"
    sleep 2
    assert_equal(before + 1, page.all('tr').count)
  end

  test "Should have validate unique accountancy code when create insurance construction" do
    click_on "Créer une assurance construction"
    fill_in "construction_insurance_rate_accountancy_code", with: "FORM"
    fill_in "construction_insurance_rate_label", with: "test"
    fill_in "construction_insurance_rate_rate", with: "5"
    click_on "Enregistrer"
    assert_selector "li", "Code comptable n'est pas disponible"
  end

  test "Should open edit insurance construction modal" do
    click_on "Créer une assurance construction"
    assert_selector "h4", "Modifier une assurance construction"
  end

  test "Should update insurance construction data" do
    all('.fa-pencil').first.click()
    fill_in "construction_insurance_rate_label", with: "Formation edited"
    click_on "Enregistrer"
    assert_selector "td", "Formation edited"
  end

  test "Should have validate unique accountancy code update insurance construction data" do
    all('.fa-pencil').first.click()
    fill_in "construction_insurance_rate_accountancy_code", with: "CONS"
    click_on "Enregistrer"
    assert_selector "li", "Code comptable n'est pas disponible"
  end

end
