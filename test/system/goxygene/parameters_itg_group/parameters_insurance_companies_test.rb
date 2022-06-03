require "application_system_test_case"
require "goxygene_set_up"

class ParametersInsuranceCompaniesTest < GoxygeneSetUp

  setup do
    visit goxygene.insurance_companies_path
  end

  test "Should open create insurance company modal" do
    click_on "Créer une compagnie d'assurance"
    assert_selector "h4", "Créer une compagnie d'assurance"
  end

  test "Should create new insurance company" do
    click_on "Créer une compagnie d'assurance"
    fill_in "insurance_company_company_attributes_corporate_name", with: "TEST"
    within "#insurance_company_insurance_type_id" do
      find("option[value='1']").click
    end
    click_on "Enregistrer"
    assert_text("TEST", wait: 2)
  end

  test "Should open edit insurance company modal" do
    all('.fa-pencil').first.click()
    assert_selector "h4", "Modifier une compagnie d'assurance"
  end

  test "Should update insurance company 'ATRADIUS'" do
    all('.fa-pencil').first.click()
    fill_in "insurance_company_company_attributes_corporate_name", with: "NEW ATRADIUS"
    click_on "Enregistrer"
    assert_text("NEW ATRADIUS", wait: 2)
  end

  test "Should have validate error insurance company message" do
    click_on "Créer une compagnie d'assurance"
    click_on "Enregistrer"
    assert_selector "li", "Compagnie d’assurance doit être rempli(e)"
  end

  test "Should have validate insurance type message" do
    click_on "Créer une compagnie d'assurance"
    click_on "Enregistrer"
    assert_selector "li", "Type d’assurance doit être rempli(e)"
  end
end
