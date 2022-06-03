require "application_system_test_case"
require "goxygene_set_up"

class ConsultantSocialsTest < GoxygeneSetUp

  setup do
    visit goxygene.consultant_socials_path(Goxygene::Consultant.find(8786))
    assert_selector "li.active", text: "CONSULTANT"
  end

  test "Should show the table" do
    assert_selector "h4", text: "SOCIAL"
    assert_selector "li.active", text: "RH"

    assert_selector "th", text: "ID"
    assert_selector "th", text: "TYPE"
    assert_selector "th", text: "HEURES TRAVAILLÉES"
    assert_selector "th", text: "DÉBUT"
    assert_selector "th", text: "STATUT"
    assert_selector "th", text: "V. MEDICALE"
    assert_selector "th", text: "FIN"
    assert_selector "th", text: "MOTIF FIN"
    assert_selector "th", text: "ENVOI"
    assert_selector "th", text: "RETOUR"
    assert_selector "th", text: "CERTIF."
    assert_selector "th", text: "SDTC"
    assert_selector "th", text: "DATE SDTC"
    assert_selector "th", text: "CERTIF"
    assert_selector "th", text: "GARANTIE"
    assert_selector "th", text: "ID SIGNATURE ÉLECTRONIQUE"
  end

  test "Should go to CDI" do
    all('td', text: 'CDI').first.click
    assert_selector "h4", text: "DÉTAIL DU CONTRAT"
    assert_selector "div.control-text", text: "CDI"
  end

  test "Should go to CDD" do
    all('td', text: 'CDD').first.click
    assert_selector "h4", text: "DÉTAIL DU CONTRAT"
    assert_selector "div.control-text", text: "CDD"
  end

  test "Should can edit CDI contract" do
    all('td', text: 'CDI').first.click
    # click_on "Editer le contrat"
    # wait for fix the novapost
  end

  test "Should can cancel contract for signature pending" do
    all('td', text: 'CDI').first.click
    assert_selector "div.control-text", text: "Attente de signature manuelle"
    click_on "Annuler le contrat"
    page.driver.browser.switch_to.alert.accept
    assert_selector "div.control-text", text: "Annulé"
  end

  test "Should can cancel unusable contract for rejected" do
    Goxygene::EmploymentContractVersion.find(34225).update status: 'rejected'

    all('td', text: 'CDI').first.click
    assert_selector "div.control-text", text: "Refusé (par le signataire)"
    click_on "Annuler le contrat"
    page.driver.browser.switch_to.alert.accept
    assert_selector "div.control-text", text: "Annulé"
  end

  test "Should can create new version for CDD" do
    emc = Goxygene::EmploymentContract.where(consultant_id: 8786, payroll_contract_type_id: 1).first
    emc.update(starting_date: (Date.today-365).strftime("%Y-%m-%d"), ended_on: (Date.today+365).strftime("%Y-%m-%d"))
    emc.employment_contract_versions.last.update(ending_date: (Date.today+15).strftime("%Y-%m-%d"))

    all('td', text: 'CDD').first.click
    click_on "Avenant au contrat"
    page.driver.browser.switch_to.alert.accept
    find('select[id*="version_type"]').find(:option, text: "Avenant CDD — changement de mission").select_option
    find('input[id*="worked_hours"]').set('10.0')
    find('input[id*="personal_development"]').set('1')
    find('input[id*="ending_date"]').set((Date.today+30).strftime("%d/%m/%Y"))

    find('input[id*="mission_order_amount"]').set('100')
    find('input[id*="mission_start"]').set(Date.today.strftime("%d/%m/%Y"))
    find('input[id*="mission_end"]').set((Date.today+15).strftime("%d/%m/%Y"))

    find('span[id*="customer_id-container"]').click
    find(:css, "input[class$='select2-search__field']").set("HSBC")
    sleep 1
    find('ul:first-child li[role*="treeitem"]').click

    find('textarea[id*="mission_description"]').set('testing')
    find('input[id*="mission_subject"]').set('testing')

    click_on "Valider et imprimer"
    click_on "Valider et imprimer sans annexes"
    # wait for fix the novapost
    # select "Avenant CDD — changement de mission", from: ""
    # sleep 20
  end

  test "Should can extend imprecise terms for CDD" do
    # skip because the database did not update
    # all('td', text: 'CDD').first.click
  end

  test "Should can release contract" do
    all('td', text: 'CDI').first.click
    click_on "Dossier de sortie"
    fill_in "employment_contract[account_settlement]", with: "10.0"
    find('#modal input[value*="Imprimer"]').click
    sleep 10
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.first)
    sleep 10
    assert_selector "div.control-text", text: "Clôturé"
  end

  test "Should can correct contract" do
    # wait for fix the novapost
    # Goxygene::EmploymentContractVersion.find(34227).update!(status: 'cancelled')
    #
    # all('td', text: 'CDD').first.click
    # click_on "Correction du contrat"
    # sleep 1
    # find('input[id*="ending_date"]').set(Date.today.strftime("%d/%m/%Y"))
    # find('input[id*="personal_development"]').set('1.0')
    # click_on "Valider et imprimer"
    # click_on "Valider et imprimer sans annexes"
    # sleep 20
  end

  test "Should can close the contract when status be validated" do
    Goxygene::EmploymentContractVersion.find(34225).update status: 'validated'

    all('td', text: 'CDI').first.click
    click_on "Clotûre"
    assert_selector "div.control-text", text: "Clôturé"
  end

  test "Should can relidate for signature pending contract" do
    all('td', text: 'CDI').first.click
    click_on "Valider le contrat"
    assert_selector "div.control-text", text: "Attente de signature manuelle"
  end

  test "Should can revalidate for corrected contract" do
    Goxygene::EmploymentContractVersion.find(34225).update status: 'validated'

    all('td', text: 'CDI').first.click
    click_on "Enregistrer"
    assert_selector "div.control-text", text: "Signé"
  end

  test "Should can cancel contract for new version?" do
    Goxygene::EmploymentContractVersion.find(34225).update status: 'new_version'

    all('td', text: 'CDI').first.click
    # skip for novapost work
  end

  test "Should can cancel contract for electronic signature pending" do
    Goxygene::EmploymentContractVersion.find(34225).update status: 'new_version'

    all('td', text: 'CDI').first.click
    # skip for novapost work
  end

  test "Should generate the pdf with appendix for CDI" do
    all('td', text: 'CDI').first.click
    click_on "Imprimer"
    click_on "Imprimer sans annexes"
    sleep 10
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert window.size > 1
  end

  test "Should generate the pdf without appendix for CDI" do
    all('td', text: 'CDI').first.click
    click_on "Imprimer"
    click_on "Imprimer avec annexes"
    sleep 15
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert window.size > 1
  end

  test "Should generate the pdf with appendix for CDD" do
    all('td', text: 'CDD').first.click
    click_on "Imprimer"
    click_on "Imprimer sans annexes"
    sleep 15
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert window.size > 1
  end

  test "Should generate the pdf without appendix for CDD" do
    all('td', text: 'CDD').first.click
    click_on "Imprimer"
    click_on "Imprimer avec annexes"
    sleep 10
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.last)
    assert window.size > 1
  end
end
