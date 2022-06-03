require "application_system_test_case"
require "goxygene_set_up"

class ParametersBaremesParameterCvsTest < GoxygeneSetUp

  setup do
    visit goxygene.baremes_parameter_cvs_path
  end

  test "Should open create baremes parameter cvs modal" do
    click_on 'Ajouter un paramètre CV'
    assert_text "Ajouter un paramètre CV", wait: 2
  end

  test "Should open edit baremes parameter modal" do
    execute_script("$('i.fa-pencil')[0].click()")
    assert_text "MODIFIER PARAMÈTRE CV", wait: 2
  end

  test "Should update baremes parameter data" do
    execute_script("$('i.fa-pencil')[0].click()")
    sleep 2
    fill_in "parameter_comment", with: "Premier palier de KM dans le calcul des frais KM new"
    fill_in "parameter_value", with: 5500
    click_on "Enregistrer"
    sleep 2
    assert_text 'Premier palier de KM dans le calcul des frais KM new'
  end

  test "Should create baremes parameter cvs on Premier type" do
    before = page.all('tr').count
    click_on 'Ajouter un paramètre CV'
    sleep 2
    within '#parameter_code' do
      find("option[value='FIRST_LEVEL_OF_KMS']").click
    end
    fill_in "parameter_value", with: 10000
    execute_script("$('#parameter_valid_from').val('30/10/2020')")
    click_on "Enregistrer"
    sleep 2
    assert_equal before + 1 , page.all('tr').count
  end

  test "Should create baremes parameter cvs on Second type" do
    before = page.all('tr').count
    click_on 'Ajouter un paramètre CV'
    sleep 2
    within '#parameter_code' do
      find("option[value='SECOND_LEVEL_OF_KMS']").click
    end
    fill_in "parameter_value", with: 10000
    execute_script("$('#parameter_valid_from').val('30/10/2020')")
    click_on "Enregistrer"
    sleep 2
    assert_equal before + 1 , page.all('tr').count
  end

  test "Should have an error when create with date less than previous data on Premier type" do
    click_on 'Ajouter un paramètre CV'
    sleep 2
    within '#parameter_code' do
      find("option[value='FIRST_LEVEL_OF_KMS']").click
    end
    fill_in "parameter_value", with: 10000
    execute_script("$('#parameter_valid_from').val('30/10/2020')")
    click_on "Enregistrer"
    sleep 2

    click_on 'Ajouter un paramètre CV'
    sleep 3
    within '#parameter_code' do
      find("option[value='FIRST_LEVEL_OF_KMS']").click
    end
    fill_in "parameter_value", with: 10000
    execute_script("$('#parameter_valid_from').val('10/10/2020')")
    click_on "Enregistrer"
    sleep 2
    assert_text "Valide à partir de doit être supérieur à Valide à partir de précédent"
  end

  test "Should have an error when create with date less than previous data on Second type" do
    click_on 'Ajouter un paramètre CV'
    sleep 2
    within '#parameter_code' do
      find("option[value='SECOND_LEVEL_OF_KMS']").click
    end
    fill_in "parameter_value", with: 10000
    execute_script("$('#parameter_valid_from').val('30/10/2020')")
    click_on "Enregistrer"
    sleep 2

    click_on 'Ajouter un paramètre CV'
    sleep 3
    within '#parameter_code' do
      find("option[value='SECOND_LEVEL_OF_KMS']").click
    end
    fill_in "parameter_value", with: 10000
    execute_script("$('#parameter_valid_from').val('10/10/2020')")
    click_on "Enregistrer"
    sleep 2
    assert_text "Valide à partir de doit être supérieur à Valide à partir de précédent"
  end

  test "Should delete baremes parameter cvs data" do
    before = page.all('tr').count
    click_on 'Ajouter un paramètre CV'
    sleep 2
    within '#parameter_code' do
      find("option[value='FIRST_LEVEL_OF_KMS']").click
    end
    fill_in "parameter_value", with: 10000
    execute_script("$('#parameter_valid_from').val('30/10/2020')")
    click_on "Enregistrer"
    sleep 2

    accept_alert do
      execute_script("$('i.fa-trash').click()")
    end
    sleep 2
    assert_equal before, page.all('tr').count
  end

end
