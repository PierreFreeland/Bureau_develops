require "application_system_test_case"
require "goxygene_set_up"

class ParametersBaremesCategoriesTest < GoxygeneSetUp

  setup do
    visit goxygene.baremes_categories_path
  end

  test "Should open create new baremes categories modal" do
    click_on "Ajout d’un type de véhicule"
    assert_text "Ajout d’un type de véhicule"
  end

  test "Should open have an error when create by using existed baremes categories name" do
    click_on "Ajout d’un type de véhicule"
    fill_in "vehicle_type_label", with: "Moto"
    click_on "Enregistrer"
    assert_text "Nom n'est pas disponible"
  end

  test "Should create new baremes categories" do
    click_on "Ajout d’un type de véhicule"
    fill_in "vehicle_type_label", with: "Utilitaire"
    click_on "Enregistrer"
    assert_text("Utilitaire", wait: 2)
  end

  test "Should open edit baremes categories modal" do
    execute_script("$('a.rounded-icons')[0].click()")
    assert_text("Éditer un type de véhicule", wait: 2)
  end

  test "Should update baremes categories name without error" do
    execute_script("$('a.rounded-icons')[0].click()")
    fill_in "vehicle_type_label", with: "Moto new"
    click_on "Enregistrer"
    assert_text("Moto new", wait: 2)
  end

  test "Should update baremes categories name without error existed name" do
    execute_script("$('a.rounded-icons')[0].click()")
    fill_in "vehicle_type_label", with: "Particulier"
    click_on "Enregistrer"
    assert_text "Nom n'est pas disponible"
  end

  test "Should update baremes categories active without error" do
    execute_script("$('a.rounded-icons')[0].click()")
    sleep 2
    execute_script("$('#vehicle_type_active_0').click()")
    click_on "Enregistrer"
    sleep 2
    assert_equal(false, Goxygene::VehicleType.first.active)
  end
end
