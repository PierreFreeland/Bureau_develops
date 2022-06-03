require "application_system_test_case"
require "goxygene_set_up"

class ParametersGeographicSubtabTest < GoxygeneSetUp

  setup do
    visit goxygene.countries_path
  end

  test "Should open create countries modal" do
    click_on "Créer un pays"
    assert_selector "h4", "Créer un pays"
  end

  test "Should create new country" do
    click_on "Créer un pays"
    fill_in "country_label", with: "TEST"
    fill_in "country_enriched_label", with: "TEST"
    fill_in "country_cog_insee", with: "TEST"
    fill_in "country_country_iso_code", with: "TE"
    fill_in "country_country_iso_code3", with: "TES"
    fill_in "country_country_iso_codenum", with: "TES"
    select "Asie", from: "country_continent_id"
    sleep 1
    select "Asie occidentale", from: "country_subcontinent_id"
    click_on "Enregistrer"


    # find new country with filter
    click_on "Filtres"
    sleep 2
    fill_in "q_label_cont", with: "TEST"
    click_on "Rechercher"
    assert_selector "h4", "TEST"
  end

  test "Should update country data" do
    all(".fa-pencil").first.click()
    new = find('#country_label').value + " edit"
    click_on "Enregistrer"

    # find new country with filter
    click_on "Filtres"
    sleep 2
    fill_in "q_label_cont", with: new
    click_on "Rechercher"
    assert_selector "h4", new
  end


end
