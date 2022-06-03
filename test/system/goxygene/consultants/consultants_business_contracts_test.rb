require "application_system_test_case"
require "goxygene_set_up"

class ConsultantsBillingRequestsTest < GoxygeneSetUp

  def assert_ci_or_cf_title
    assert has_selector?("h4", text: "CONTRAT DE PRESTATION") || has_selector?("h4", text: "CONVENTION DE FORMATION")
  end

  test "Should redirect to consultants business contracts index" do
    visit goxygene.consultants_business_contracts_path
    assert_selector "h4", "DEMANDES DE CONTRATS"
  end

  test "Should redirect back to Conseiller de gestion from consultants business contracts" do
    visit goxygene.consultants_business_contracts_path
    click_on "Retour"
    assert_selector "h4", "LES CHIFFRES #{Goxygene::Parameter.value_for_group}"
  end

  test "Should redirect to consultants business contracts detail" do
    visit goxygene.consultants_business_contracts_path
    all(".list-table tbody tr").first.click
    assert_ci_or_cf_title
  end

  test "Should redirect to consultant timeline page from consultants business contracts" do
    visit goxygene.consultants_business_contracts_path
    consultant_name = all(".list-table tbody tr").first.all("a").first.text
    all(".list-table tbody tr").first.all("a").first.click
    assert_selector "h4", consultant_name
  end

  test "Should accept demande de contrat" do
    visit goxygene.consultants_business_contracts_path
    accept_alert do
      execute_script('$("a[data-title=\"Accepter la demande de contrat\"]")[0].click()')
    end
    sleep 2
    assert_ci_or_cf_title
  end

  test "Should validate demande de contrat" do
    visit goxygene.consultants_business_contracts_path
    execute_script('$("span[data-title=\"Valider\"]")[0].click()')
    sleep 1
    fill_in "establishment_name", with: "test"
    execute_script('$("#establishment_is_natural_person").click()')
    click_on "Enregistrer"
    assert_ci_or_cf_title
  end

  test "Should refuse demande de contrat" do
    visit goxygene.consultants_business_contracts_path
    before = all(".list-table tbody tr").size
    accept_alert do
      execute_script('$("a[data-title=\"Refuser la demande de contrat\"]")[0].click()')
    end
    sleep 2
    assert_equal before - 1, all(".list-table tbody tr").size
  end

  test "Should delete demande de contrat" do
    visit goxygene.consultants_business_contracts_path
    before = all(".list-table tbody tr").size
    accept_alert do
      execute_script('$("a[data-title=\"Supprimer la demande de contrat\"]")[0].click()')
    end
    sleep 2
    assert_equal before - 1, all(".list-table tbody tr").size
  end

  test "Should resend demande de contrat" do
    visit goxygene.consultants_business_contracts_path
    before = all(".list-table tbody tr").size
    accept_alert do
      execute_script('$("a[data-title=\"Renvoyer la demande de contrat\"]")[0].click()')
    end
    sleep 2
    assert_equal before - 1, all(".list-table tbody tr").size
  end

  test "Should accept demande de contrat cf type on detail" do
    visit goxygene.consultants_business_contract_path(Goxygene::OfficeBusinessContract.find(35710))
    click_on "Accepter"
    sleep 1
    fill_in "establishment_name", with: "test"
    execute_script('$("#establishment_is_natural_person").click()')
    click_on "Enregistrer"
    assert_selector "h4", "CONVENTION DE FORMATION"
  end

  test "Should refuse demande de contrat cf type on detail" do
    visit goxygene.consultants_business_contract_path(Goxygene::OfficeBusinessContract.find(35710))
    accept_alert do
      click_on "Rejeter"
    end
    assert_selector "h4", "DEMANDES DE CONTRATS"
  end

  test "Should delete demande de contrat cf type on detail" do
    visit goxygene.consultants_business_contract_path(Goxygene::OfficeBusinessContract.find(35710))
    accept_alert do
      click_on "Supprimer"
    end
    assert_selector "h4", "DEMANDES DE CONTRATS"
  end

  test "Should resend demande de contrat cf type on detail" do
    visit goxygene.consultants_business_contract_path(Goxygene::OfficeBusinessContract.find(35710))
    accept_alert do
      click_on "Renvoyer"
    end
    assert_selector "h4", "DEMANDES DE CONTRATS"
  end

  test "Should print new demande de contrat cf type pdf on detail" do
    visit goxygene.consultants_business_contract_path(Goxygene::OfficeBusinessContract.find(35710))
    before =  all(".fa-file-pdf-o").size
    click_on "Imprimer"
    sleep 1
    assert_equal before + 1,  all(".fa-file-pdf-o").size
  end

  test "Should accept demande de contrat ci type on detail" do
    visit goxygene.consultants_business_contract_path(Goxygene::OfficeBusinessContract.find(31300))
    click_on "Accepter"
    sleep 1
    fill_in "establishment_name", with: "test"
    execute_script('$("#establishment_is_natural_person").click()')
    click_on "Enregistrer"
    assert_selector "h4", "CONTRAT DE PRESTATION"
  end

  test "Should refuse demande de contrat ci type on detail" do
    visit goxygene.consultants_business_contract_path(Goxygene::OfficeBusinessContract.find(31300))
    accept_alert do
      click_on "Rejeter"
    end
    assert_selector "h4", "DEMANDES DE CONTRATS"
  end

  test "Should delete demande de contrat ci type on detail" do
    visit goxygene.consultants_business_contract_path(Goxygene::OfficeBusinessContract.find(31300))
    accept_alert do
      click_on "Supprimer"
    end
    assert_selector "h4", "DEMANDES DE CONTRATS"
  end

  test "Should resend demande de contrat ci type on detail" do
    visit goxygene.consultants_business_contract_path(Goxygene::OfficeBusinessContract.find(31300))
    accept_alert do
      click_on "Renvoyer"
    end
    assert_selector "h4", "DEMANDES DE CONTRATS"
  end

  test "Should print new demande de contrat ci type pdf on detail" do
    visit goxygene.consultants_business_contract_path(Goxygene::OfficeBusinessContract.find(31300))
    before =  all(".fa-file-pdf-o").size
    click_on "Imprimer"
    sleep 1
    assert_equal before + 1,  all(".fa-file-pdf-o").size
  end

  test "Should preview pdf on detail" do
    visit goxygene.consultants_business_contract_path(Goxygene::OfficeBusinessContract.find(31300))
    click_on "Imprimer"
    sleep 1
    execute_script('$("i.fa-file-pdf-o").closest("td").children("a")[0].click()')
    sleep 1
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert has_selector? 'embed[type="application/pdf"]'
  end

  test "Should filter by consultant name" do
    visit goxygene.consultants_business_contracts_path
    find(".fa-filter").click
    sleep 1
    all(".selection-counter")[1].click
    sleep 1
    selected_consultant = all(".select2-results__option")[1].text
    all(".select2-results__option")[1].click
    execute_script('$("input[value=\"Rechercher\"]").click()')

    result = []
    all(".list-table tbody tr").each do |tr|
      if selected_consultant.include?(tr.all("a")[0].text)
        result << true
      else
        result << false
      end
    end
    assert !result.include?(false)
  end

  test "Should filter by facturation ht" do
    visit goxygene.consultants_business_contracts_path
    find(".fa-filter").click
    sleep 1
    fill_in "q_order_amount_euros_gteq", with: "100"
    execute_script('$("input[value=\"Rechercher\"]").click()')

    result = []
    all(".list-table tbody tr").each do |tr|
      if tr.all("td")[7].text.to_i > 100
        result << true
      else
        result << false
      end
    end
    assert !result.include?(false)
  end

  test "Should filter by Contrats period" do
    visit goxygene.consultants_business_contracts_path
    find(".fa-filter").click
    sleep 1
    execute_script("$('#q_begining_date_gteq').val('01/05/2017')")
    execute_script("$('#q_ending_date_lteq').val('01/10/2017')")
    execute_script('$("input[value=\"Rechercher\"]").click()')

    result = []
    all(".list-table tbody tr").each do |tr|
      if ('01/05/2017'.to_date..'01/10/2017'.to_date).include?(tr.all("td")[5].text.to_date..tr.all("td")[6].text.to_date)
        result << true
      else
        result << false
      end
    end
    assert !result.include?(false)
  end
end

