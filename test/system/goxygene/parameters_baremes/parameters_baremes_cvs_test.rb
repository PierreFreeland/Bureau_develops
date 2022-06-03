require "application_system_test_case"
require "goxygene_set_up"

class ParametersBaremesCvsTest < GoxygeneSetUp

  setup do
    visit goxygene.baremes_cvs_path
  end

  test "Should open edit baremes cvs modal" do
    execute_script("$('a.rounded-icons')[0].click()")
    assert_text("Taux des CV", wait: 2)
  end

  test "Should update baremes cvs without error" do
    execute_script("$('a.rounded-icons')[0].click()")
    sleep 2
    fill_in "vehicle_taxe_weight_taxe_weigth", with: 15
    fill_in "vehicle_taxe_weight_rate1", with: 1
    fill_in "vehicle_taxe_weight_rate2", with: 1
    fill_in "vehicle_taxe_weight_rate3", with: 1
    execute_script("$('#vehicle_taxe_weight_active_0').click()")
    click_on "Enregistrer"

    assert_text(15, wait: 2)
  end
end
