require "application_system_test_case"
require "goxygene_set_up"

class EstablishmentRegulationsChecksTest < GoxygeneSetUp
  setup do
    visit goxygene.establishment_checks_regulations_path(Goxygene::Establishment.last)
    assert_selector "h4", text: "ENCAISSEMENT"
  end

  test "Should create and redirect to edit page" do
    click_on 'Créer un règlement'

    fill_in "customer_payment[target_date]", with: "#{Date.today.strftime("%d/%m/%Y")}"
    within "#customer_payment_itg_company_id" do
      all('option')[1].click
    end
    click_on 'Enregistrer'

    assert_selector "td", text: "#{Date.today.strftime("%d/%m/%Y")}"
    assert_selector "td", text: "Institut du Temps Géré"

    all('tr').last.click
    sleep 20
    assert_selector "h4", text: "Modifier le règlement"
  end

  test "Should show filter" do
    click_on 'Filtres'
    assert_selector "#q_date_gteq[value='#{(Date.today.beginning_of_year - 1.year).strftime("%d/%m/%Y")}']"
    assert_selector "#q_date_lteq[value='#{(Date.today.end_of_year).strftime("%d/%m/%Y")}']"
  end
end