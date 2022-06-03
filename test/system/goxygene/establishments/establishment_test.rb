require "application_system_test_case"
require "goxygene_set_up"

class EstablishmentDataTest < GoxygeneSetUp

  setup do
    visit goxygene.establishment_timelines_path(Goxygene::Establishment.first)
  end

  test "Should redirect page" do
    within '.nav-middle' do
      click_on "Timeline"
    end

    assert_selector "li.active a", text: "TIMELINE"
  end

  test "Should go to establishment data page" do
    within '.nav-middle' do
      click_on "Données établissement"
    end

    assert_selector "li.active a", text: "DONNÉES ÉTABLISSEMENT"
  end

  test "Should go to establishment contact_managements page" do
    ActiveRecord::Migration.enable_extension "unaccent"
    within '.nav-middle' do
      click_on "Fiches contacts"
    end

    assert_selector "li.active a", text: "FICHES CONTACTS"
  end

  test "Should go to establishment billings page" do
    within '.nav-middle' do
      click_on "Factures"
    end

    assert_selector "li.active a", text: "FACTURES"
  end

  test "Should go to establishment accounts infos page" do
    within '.nav-middle' do
      click_on "Comptabilité"
    end

    assert_selector "li.active a", text: "COMPTABILITÉ"
  end

  test "Should go to establishment regulations check page" do
    within '.nav-middle' do
      click_on "Encaissements"
    end

    assert_selector "li.active a", text: "ENCAISSEMENTS"
  end

  test "Should go to establishment consultants page" do
    within '.nav-middle' do
      click_on "Consultants"
    end

    assert_selector "li.active a", text: "CONSULTANTS"
  end

  test "Should go to establishment business contracts page" do
    within '.nav-middle' do
      click_on "Contrats commerciaux"
    end

    assert_selector "li.active a", text: "CONTRATS COMMERCIAUX"
  end

  test "Should go to establishment reminders page" do
    within '.nav-middle' do
      click_on "Rappels"
    end

    assert_selector "li.active a", text: "RAPPELS"
  end
end
