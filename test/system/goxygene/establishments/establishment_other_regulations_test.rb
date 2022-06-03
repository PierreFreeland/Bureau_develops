require "application_system_test_case"
require "goxygene_set_up"

class EstablishmentOtherRegulationsTest < GoxygeneSetUp
  setup do
    visit goxygene.establishment_other_regulations_path(Goxygene::Establishment.last)
    assert_selector "h4", text: "RÈGLEMENTS"
  end

  test "Should create regulation type Compensation" do
    click_on 'Créer un règlement'
    sleep 2
    select "Compensation", from: "customer_accounting_transaction_accounting_transaction"
    sleep 2
    # assert_selector "#customer_accounting_transaction_tier_kind", text: "FOU"
    assert_selector "#customer_accounting_transaction_tier_code", text: "Aucun tiers"
    assert_selector "#customer_accounting_transaction_account", text: "4011000000 - FOURNISSEURS"

    select "ACPI Exécutive", from: "customer_accounting_transaction[itg_company_id]"
    fill_in "customer_accounting_transaction[date]", with: "#{Date.today.strftime("%d/%m/%Y")}"
    click_on 'Enregistrer'

    assert_selector "tr:last-child td", text: "Compensation"
  end

  test "Should show error message when create regulation type Compensation" do
    click_on 'Créer un règlement'
    sleep 2
    select "Compensation", from: "customer_accounting_transaction_accounting_transaction"
    sleep 2
    click_on 'Enregistrer'

    assert_selector ".alert-danger li", text: "Tier doit être rempli(e)"
    assert_selector ".alert-danger li", text: "Date doit être rempli(e)"
    assert_selector ".alert-danger li", text: "Société #{Goxygene::Parameter.value_for_group} doit être rempli(e)"
  end

  test "Should create regulation type Caisse" do
    click_on 'Créer un règlement'
    sleep 2
    select "Caisse", from: "customer_accounting_transaction_accounting_transaction"
    sleep 2
    assert_selector "#customer_accounting_transaction_tier_code", text: "CAISSE"
    assert_selector "#customer_accounting_transaction_account", text: "5310000000 - CAISSE"

    select "ACPI Exécutive", from: "customer_accounting_transaction[itg_company_id]"
    fill_in "customer_accounting_transaction[date]", with: "#{Date.today.strftime("%d/%m/%Y")}"
    click_on 'Enregistrer'

    assert_selector "tr:last-child td", text: "Caisse"
  end

  test "Should show error message when create regulation type Caisse" do
    click_on 'Créer un règlement'
    sleep 2
    select "Caisse", from: "customer_accounting_transaction_accounting_transaction"
    sleep 2
    click_on 'Enregistrer'

    assert_selector ".alert-danger li", text: "Date doit être rempli(e)"
    assert_selector ".alert-danger li", text: "Société #{Goxygene::Parameter.value_for_group} doit être rempli(e)"
  end

  test "Should create regulation type Ecart Change" do
    click_on 'Créer un règlement'
    sleep 2
    select "Ecart Change", from: "customer_accounting_transaction_accounting_transaction"
    sleep 2
    assert_selector "#customer_accounting_transaction_account", text: "6666000000 - PERTES DE CHANGE"

    select "ACPI Exécutive", from: "customer_accounting_transaction[itg_company_id]"
    fill_in "customer_accounting_transaction[date]", with: "#{Date.today.strftime("%d/%m/%Y")}"
    click_on 'Enregistrer'

    assert_selector "tr:last-child td", text: "Ecart Change"
  end

  test "Should show error message when create regulation type Ecart Change" do
    click_on 'Créer un règlement'
    sleep 2
    select "Ecart Change", from: "customer_accounting_transaction_accounting_transaction"
    sleep 2
    click_on 'Enregistrer'

    assert_selector ".alert-danger li", text: "Date doit être rempli(e)"
    assert_selector ".alert-danger li", text: "Société #{Goxygene::Parameter.value_for_group} doit être rempli(e)"
  end

  test "Should create regulation type Autres and redirect to detail" do
    click_on 'Créer un règlement'
    sleep 2
    select "Autres", from: "customer_accounting_transaction_accounting_transaction"
    sleep 2
    assert_selector "#customer_accounting_transaction_tier_kind"
    assert_selector "#customer_accounting_transaction_tier_code", text: "Aucun tiers"

    select "ACPI Exécutive", from: "customer_accounting_transaction[itg_company_id]"
    select "101 - CAPITAL", from: "customer_accounting_transaction[account]"
    fill_in "customer_accounting_transaction[date]", with: "#{Date.today.strftime("%d/%m/%Y")}"
    click_on 'Enregistrer'

    assert_selector "tr:last-child td", text: "Autres"

    all('tr').last.click
    sleep 2
    assert_selector "h4", text: "Modifier le règlement"

    fill_in "customer_accounting_transaction[comment]", with: "test"
    click_on 'Enregistrer'
    assert_selector "#customer_accounting_transaction_comment", text: "test"

    click_on 'Choisir des factures'
    sleep 2
    assert_selector ".modal h4", text: "FACTURES À RÉGLER"
    sleep 1
    find('.close').click

    click_on 'Annuler le règlement'
    sleep 2
    assert_selector "div", text: "Annulé"
  end

  test "Should show error message when create regulation type Autres" do
    click_on 'Créer un règlement'
    sleep 2
    select "Autres", from: "customer_accounting_transaction_accounting_transaction"
    sleep 2
    click_on 'Enregistrer'

    assert_selector ".alert-danger li", text: "Date doit être rempli(e)"
    assert_selector ".alert-danger li", text: "Société #{Goxygene::Parameter.value_for_group} doit être rempli(e)"
  end

  test "Should show filter" do
    click_on 'Filtres'
    assert_selector "#q_date_gteq[value='#{(Date.today.beginning_of_year - 1.year).strftime("%d/%m/%Y")}']"
    assert_selector "#q_date_lteq[value='#{(Date.today.end_of_year).strftime("%d/%m/%Y")}']"
  end
end