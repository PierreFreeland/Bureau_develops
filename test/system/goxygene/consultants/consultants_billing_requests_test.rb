require "application_system_test_case"
require "goxygene_set_up"

class ConsultantsBillingRequestsTest < GoxygeneSetUp

  def visit_consultants_billing_request_index
    visit goxygene.consultants_billing_requests_path
  end

  def visit_consultants_billing_request_show
    visit goxygene.consultants_billing_request_path(294259)
  end

  test "Should redirect to consultants billing requests index" do
    visit_consultants_billing_request_index
    assert_selector "h4", "DEMANDES DE FACTURES"
  end

  test "Should redirect back to Conseiller de gestion from consultants billing requests" do
    visit_consultants_billing_request_index
    click_on "Retour"
    assert_selector "h4", "LES CHIFFRES #{Goxygene::Parameter.value_for_group}"
  end

  test "Should redirect to consultants billing request detail" do
    visit_consultants_billing_request_index
    all(".list-table tbody tr").first.click
    assert_selector "h4", "DÉTAILS"
  end

  test "Should redirect to consultant timeline page from consultants billing requests" do
    visit_consultants_billing_request_index
    text = all(".list-table tbody tr").first.all("a")[0].text
    all(".list-table tbody tr").first.all("a")[0].click
    assert_selector "h4", text
  end

  test "Should redirect to client timeline page" do
    visit_consultants_billing_request_index
    text = all(".list-table tbody tr").first.all("a")[1].text
    all(".list-table tbody tr").first.all("a")[1].click
    assert_selector "h4", text
  end

  test "Should filter demande de facture on status refuse" do
    visit_consultants_billing_request_index
    find(".fa-filter").click
    execute_script('$("#q_status_query_rejected").click()')
    click_on "Rechercher"
    sleep 1
    all(".list-table tbody tr").first.click
    assert_selector "div", "Facture refusée"
  end

  test "Should filter demande de facture on consultant name" do
    visit_consultants_billing_request_index
    find(".fa-filter").click
    sleep 1
    all(".selection-counter")[1].click
    sleep 1
    selected_consultant = all(".select2-results__option")[1].text
    all(".select2-results__option")[1].click
    click_on "Rechercher"

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

  test "Should open preview pdf" do
    visit_consultants_billing_request_index
    execute_script("$('.fa-file-pdf-o')[0].click()")
    sleep 5
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert has_selector? 'embed[type="application/pdf"]'
  end


  test "Should accept demande de facture" do
    visit_consultants_billing_request_index
    accept_alert do
      execute_script('$("a[data-title=\"Accepter la demande de facture\"]")[0].click()')
    end
    sleep 5
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert has_selector? 'embed[type="application/pdf"]'
  end

  test "Should refuse demande de facture" do
    visit_consultants_billing_request_index
    before = all(".list-table tbody tr").size
    accept_alert do
      execute_script('$("a[data-title=\"Refuser la demande de facture\"]")[0].click()')
    end
    sleep 2
    assert_equal before - 1, all(".list-table tbody tr").size
  end

  test "Should delete demande de facture" do
    visit_consultants_billing_request_index
    before = all(".list-table tbody tr").size
    accept_alert do
      execute_script('$("a[data-title=\"Supprimer la demande de facture\"]")[0].click()')
    end
    sleep 2
    assert_equal before - 1, all(".list-table tbody tr").size
  end

  test "Should resend demande de facture" do
    visit_consultants_billing_request_index
    before = all(".list-table tbody tr").size
    accept_alert do
      execute_script('$("a[data-title=\"Renvoyer la demande de facture\"]")[0].click()')
    end
    sleep 2
    assert_equal before - 1, all(".list-table tbody tr").size
  end

  test "Should refuse demande de facture on detail page" do
    visit_consultants_billing_request_show
    all(".list-table tbody tr").first.click
    accept_alert do
      sleep 2
      click_on "Rejeter"
    end
    assert_selector "div", "Facture refusée"
  end

  test "Should accept demande de facture on detail page" do
    visit_consultants_billing_request_show
    all(".list-table tbody tr").first.click
    accept_alert do
      sleep 2
      click_on "Accepter"
    end
    sleep 2
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert has_selector? 'embed[type="application/pdf"]'
  end

  test "Should delete demande de facture on detail page" do
    visit_consultants_billing_request_show
    all(".list-table tbody tr").first.click
    accept_alert do
      sleep 2
      click_on "Supprimer"
    end
    assert_selector "h4", "DEMANDES DE FACTURES"
  end

  test "Should resend demande de facture on detail page" do
    visit_consultants_billing_request_show
    all(".list-table tbody tr").first.click
    accept_alert do
      sleep 2
      click_on "Renvoyer"
    end
    assert_selector "h4", "DEMANDES DE FACTURES"
  end

end

