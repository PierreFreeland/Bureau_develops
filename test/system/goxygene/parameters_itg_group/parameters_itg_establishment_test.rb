require "application_system_test_case"
require "goxygene_set_up"

class ParametersItgEstablishmentTest < GoxygeneSetUp

  setup do
    visit goxygene.itg_establishment_index_path
  end

  test "Should open create itg establishment modal" do
    click_on "Créer un Établissement #{Goxygene::Parameter.value_for_group}"
    assert_selector "h4", "Créer un Établissement #{Goxygene::Parameter.value_for_group}"
  end

  test "Should create new itg establishment" do
    click_on "Créer un Établissement #{Goxygene::Parameter.value_for_group}"
    fill_in "itg_establishment_name", with: "Test"
    within "#itg_establishment_itg_company_id" do
      find("option[value='300']").click
    end
    fill_in "itg_establishment_contact_datum_attributes_address_2", with: "test address"

    # fill zipcode select2
    all('.select2')[0].click
    find(:css, "input[class$='select2-search__field']").set("123")
    sleep(1)
    all('.select2-results__option')[0].click

    fill_in "itg_establishment_siret", with: "32830386376851"
    execute_script("$('#itg_establishment_opened_on').val('#{Date.today.strftime("%d/%m/%Y")}')")
    fill_in "itg_establishment_payroll_code", with: "99"

    click_on "Enregistrer"
    assert_selector "td", "Test"
  end

  test "Should have siret not match with siren message when create itg establishment" do
    click_on "Créer un Établissement #{Goxygene::Parameter.value_for_group}"
    fill_in "itg_establishment_name", with: "Test"
    within "#itg_establishment_itg_company_id" do
      find("option[value='300']").click
    end
    fill_in "itg_establishment_contact_datum_attributes_address_2", with: "test address"

    # fill zipcode select2
    all('.select2')[0].click
    find(:css, "input[class$='select2-search__field']").set("123")
    sleep(1)
    all('.select2-results__option')[0].click

    fill_in "itg_establishment_siret", with: "11111111111111"
    execute_script("$('#itg_establishment_opened_on').val('#{Date.today.strftime("%d/%m/%Y")}')")
    fill_in "itg_establishment_payroll_code", with: "99"

    click_on "Enregistrer"
    assert_selector "li", "Les numéros de SIRET et SIREN ne correspondent pas. Merci de vérifier le numéro de SIRET"
  end

  test "Should have siret format error message when create itg establishment" do
    click_on "Créer un Établissement #{Goxygene::Parameter.value_for_group}"
    fill_in "itg_establishment_name", with: "Test"
    within "#itg_establishment_itg_company_id" do
      find("option[value='300']").click
    end
    fill_in "itg_establishment_contact_datum_attributes_address_2", with: "test address"

    # fill zipcode select2
    all('.select2')[0].click
    find(:css, "input[class$='select2-search__field']").set("123")
    sleep(1)
    all('.select2-results__option')[0].click

    fill_in "itg_establishment_siret", with: "1111111111"
    execute_script("$('#itg_establishment_opened_on').val('#{Date.today.strftime("%d/%m/%Y")}')")
    fill_in "itg_establishment_payroll_code", with: "99"

    click_on "Enregistrer"
    assert_selector "li", "Le SIRET doit être composé de 14 chiffres."
  end

  test "Should have siret not valid message when create itg establishment" do
    click_on "Créer un Établissement #{Goxygene::Parameter.value_for_group}"
    fill_in "itg_establishment_name", with: "Test"
    within "#itg_establishment_itg_company_id" do
      find("option[value='300']").click
    end
    fill_in "itg_establishment_contact_datum_attributes_address_2", with: "test address"

    # fill zipcode select2
    all('.select2')[0].click
    find(:css, "input[class$='select2-search__field']").set("123")
    sleep(1)
    all('.select2-results__option')[0].click

    fill_in "itg_establishment_siret", with: "32830386370000"
    execute_script("$('#itg_establishment_opened_on').val('#{Date.today.strftime("%d/%m/%Y")}')")
    fill_in "itg_establishment_payroll_code", with: "99"

    click_on "Enregistrer"
    assert_selector "li", "Le SIRET n'est pas valide"
  end


  test "Should open edit itg establishment modal" do
    all('.fa-pencil').first.click()
    assert_selector "h4", "Modifier Etablissements #{Goxygene::Parameter.value_for_group}"
  end

  test "Should update itg establishment" do
    all('.fa-pencil')[1].click()
    fill_in "itg_establishment_name", with: "EDITED Test"
    click_on "Enregistrer"
    assert_selector "td", "EDITED Test"
  end

end
