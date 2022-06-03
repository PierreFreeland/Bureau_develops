require "application_system_test_case"
require "goxygene_set_up"

class EstablishmentRegulationsTransfersTest < GoxygeneSetUp
  setup do
    visit goxygene.establishment_transfers_regulations_path(Goxygene::Establishment.last)
    assert_selector "h4", text: "ENCAISSEMENT"
  end

  test "Should show error message" do
    click_on 'Créer un règlement'
    click_on 'Enregistrer'

    assert_selector ".alert-danger li",text: "Société doit être rempli(e)"
    assert_selector ".alert-danger li",text: "Banque doit être rempli(e)"
  end

  test "Should create and redirect to edit page" do
    click_on 'Créer un règlement'

    within "#customer_payment_itg_company_id" do
      all('option')[1].click
    end
    sleep 2
    within "#customer_payment_itg_bank_account_id" do
      all('option')[1].click
    end
    click_on 'Enregistrer'

    assert_selector "td",text: "PARIS BOURSE ENTREPRISE 2"
    assert_selector "td",text: "Institut du Temps Géré"

    all('tr').last.click
    sleep 2
    assert_selector "h4",text: "Modifier le règlement"
  end

  test "Should show filter" do
    click_on 'Filtres'
    assert_selector "#q_date_gteq[value='#{(Date.today.beginning_of_year - 1.year).strftime("%d/%m/%Y")}']"
    assert_selector "#q_date_lteq[value='#{(Date.today.end_of_year).strftime("%d/%m/%Y")}']"
  end
end