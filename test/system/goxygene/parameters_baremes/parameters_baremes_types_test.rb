require "application_system_test_case"
require "goxygene_set_up"

class ParametersBaremesTypesTest < GoxygeneSetUp

  setup do
    visit goxygene.baremes_types_path
  end

  test "Should open create new baremes type modal" do
    click_on "Ajout un type d’énergie de véhicule"
    assert_text "Ajout un type d’énergie de véhicule"
  end

  test "Should open have an error when create by using existed baremes type name" do
    click_on "Ajout un type d’énergie de véhicule"
    fill_in "vehicle_energy_label", with: "Essence"
    click_on "Enregistrer"
    assert_text "Nom n'est pas disponible"
  end

  test "Should create new baremes type" do
    click_on "Ajout un type d’énergie de véhicule"
    fill_in "vehicle_energy_label", with: "Gazole"
    click_on "Enregistrer"
    assert_text("Gazole", wait: 2)
  end

  test "Should open edit baremes type modal" do
    execute_script("$('a.rounded-icons')[0].click()")
    assert_text("Éditer un type d’énergie de véhicule", wait: 2)
  end

  test "Should update baremes type name" do
    execute_script("$('a.rounded-icons')[0].click()")
    fill_in "vehicle_energy_label", with: "Essence new"
    click_on "Enregistrer"
    assert_text("Essence new", wait: 2)
  end

  test "Should open have an error when update by using existed baremes type name" do
    execute_script("$('a.rounded-icons')[0].click()")
    fill_in "vehicle_energy_label", with: "Electrique"
    click_on "Enregistrer"
    assert_text "Nom n'est pas disponible"
  end

  test "Should update baremes type active" do
    execute_script("$('a.rounded-icons')[0].click()")
    sleep 2
    execute_script("$('#vehicle_energy_active_0').click()")
    click_on "Enregistrer"
    sleep 2
    assert_equal(false, Goxygene::VehicleEnergy.first.active)
  end
end
