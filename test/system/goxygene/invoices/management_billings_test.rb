require "application_system_test_case"
require "goxygene_set_up"

class ManagementsTest < GoxygeneSetUp

  test "Should redirect to new invoice page" do
    visit goxygene.managements_billings_path
    click_on "Créer une facture"
    assert_selector "h4", text: "CRÉATION D’UNE FACTURE DE PORTAGE SALARIALE"
  end

  test "Should show filter section" do
    visit goxygene.managements_billings_path
    click_on "Filtres"
    assert_selector "label", text: "à partir de"
  end

  test "Should redirect to invoice detail from invoice page" do
    visit goxygene.managements_billings_path
    page.all('tr')[1].click
    assert_selector "h4", text: "DÉTAILS"
  end

end