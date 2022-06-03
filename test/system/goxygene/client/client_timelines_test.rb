require "application_system_test_case"
require "goxygene_set_up"

class ClientTimelinesTest < GoxygeneSetUp
  setup do
    visit goxygene.client_timelines_path(Goxygene::Customer.last)
  end

  test "Should change status" do
    assert_selector ".dashboard-top-prospect h4", text: Goxygene::Customer.last.company.corporate_name
    find("a[href='/goxygene/clients/#{Goxygene::Customer.last.id}/active']").click
    assert_selector "h4.modal-title",text: "ACTIF"
    sleep 1
    select "En proposition", from: "customer_status"
    fill_in "timeline_comment", with: "test"
    click_on "Valider"
    sleep 2
    assert_selector "a[href='/goxygene/clients/#{Goxygene::Customer.last.id}/active'] div.font-bg-circle",text: "En proposition"
  end

  test "Should redirect to bussiness contracts and consultants" do
    find(".dashboard-top-prospect a[href='/goxygene/clients/#{Goxygene::Customer.last.id}/business_contracts']").click
    assert_selector "h4",text: "CONTRATS COMMERCIAUX"

    find(".dashboard-top-prospect a[href='/goxygene/clients/#{Goxygene::Customer.last.id}/consultants']").click
    assert_selector "h4",text: "CONSULTANTS"
  end

  test "Should change finance status to non" do
    find(".dashboard-top-prospect a[href='/goxygene/clients/#{Goxygene::Customer.last.id}/financial']").click
    assert_selector "h4.modal-title",text: "Finance"
    find("label[for='radio4-non']").click
    click_on "Enregistrer"
    sleep 2
    assert_selector "a[href='/goxygene/clients/#{Goxygene::Customer.last.id}/financial'] .bg-red"
  end

  test "Should change finance status to dont know" do
    find(".dashboard-top-prospect a[href='/goxygene/clients/#{Goxygene::Customer.last.id}/financial']").click
    assert_selector "h4.modal-title",text: "Finance"
    find("label[for='radio4-je']").click
    click_on "Enregistrer"
    sleep 2
    assert_selector "a[href='/goxygene/clients/#{Goxygene::Customer.last.id}/financial'] .bg-yellow"
  end

  test "Should save key details" do
    assert_selector "div",text: "Raison Sociale : #{Goxygene::Customer.last.company.corporate_name}"
    find("input[data-url='/goxygene/clients/#{Goxygene::Customer.last.id}/toggle_referenced']", visible: false).set(false)
    page.execute_script('location.reload();')
    sleep 1
    assert_equal false, page.find("input[data-url='/goxygene/clients/#{Goxygene::Customer.last.id}/toggle_referenced']", visible: false).checked?
  end

  test "Should show error message when create skype" do
    page.find(".circle-add").click
    assert_selector "h4",text: "NOUVELLE ACTION :"
    sleep 1

    page.find("label[data-target='#tab-skype']").click
    sleep 1
    assert_selector "label",text: "Date"

    click_on "Ajouter"
    assert_selector '.alert-danger li',text: "Timeline type doit exister"
    assert_selector '.alert-danger li',text: "Status doit être rempli(e)"
  end

  test "Should create skype" do
    page.find(".circle-add").click
    assert_selector "h4",text: "NOUVELLE ACTION :"
    sleep 1

    page.find("label[data-target='#tab-skype']").click
    sleep 1
    assert_selector "label",text: "Date"

    page.find("label[for=communication_timeline_type_id_16]").click
    sleep 1

    page.find("label[for=communication_status_done]").click
    sleep 1

    click_on "Ajouter"
    assert_selector 'span.text-bolder',text: "#{Goxygene::TimelineType.find(16).label} -"
    assert_selector 'span',text: "#{Date.today.strftime("%d/%m/%Y")}"
  end

  test "Should show error message when create call" do
    page.find(".circle-add").click
    assert_selector "h4",text: "NOUVELLE ACTION :"
    sleep 1

    page.find("label[data-target='#tab-call']").click
    sleep 1
    assert_selector "label",text: "Date"

    click_on "Ajouter"
    assert_selector '.alert-danger li',text: "Timeline type doit exister"
    assert_selector '.alert-danger li',text: "Status doit être rempli(e)"
  end

  test "Should create call" do
    page.find(".circle-add").click
    assert_selector "h4",text: "NOUVELLE ACTION :"
    sleep 1

    page.find("label[data-target='#tab-call']").click
    sleep 1
    assert_selector "label",text: "Date"

    page.find("label[for=communication_timeline_type_id_3]").click
    sleep 1

    page.find("label[for=communication_status_done]").click
    sleep 1

    click_on "Ajouter"
    assert_selector 'span.text-bolder',text: "#{Goxygene::TimelineType.find(3).label} -"
    assert_selector 'span',text: "#{Date.today.strftime("%d/%m/%Y")}"
  end

  # test "Should show error message when create sms" do
  #   page.find(".circle-add").click
  #   assert_selector "h4",text: "NOUVELLE ACTION :"
  #   sleep 1
  #
  #   page.find("label[data-target='#tab-sms']").click
  #   sleep 1
  #   assert_selector ".email-title", text: "BIBLIOTHÈQUE DE MESSAGES"
  #
  #   click_on "Envoyer"
  #   assert_selector '.alert-danger li',text: "De doit être rempli(e)"
  #   assert_selector '.alert-danger li',text: "À doit être rempli(e)"
  #   assert_selector '.alert-danger li',text: "Contenu du SMS doit être rempli(e)"
  # end

  # test "Should create sms" do
  #   page.find(".circle-add").click
  #   assert_selector "h4",text: "NOUVELLE ACTION :"
  #   sleep 1
  #
  #   page.find("label[data-target='#tab-sms']").click
  #   sleep 1
  #   assert_selector ".email-title", text: "BIBLIOTHÈQUE DE MESSAGES"
  #
  #   fill_in "timeline_sms[from]", with: "test"
  #   fill_in "timeline_sms[to]", with: "test"
  #   fill_in "timeline_sms[body]", with: "test"
  #   # byebug
  #   sleep 1
  #
  #   click_on "Envoyer"
  #   assert_selector 'span.text-bolder',text: "#{Goxygene::TimelineType.find(7).label} -"
  #   assert_selector 'span',text: "#{Date.today.strftime("%d/%m/%Y")}"
  # end

  test "Should show error message when create email" do
    page.find(".circle-add").click
    assert_selector "h4",text: "NOUVELLE ACTION :"
    sleep 1

    page.find("label[data-target='#tab-email']").click
    sleep 1
    # assert_selector ".email-title", text: "BIBLIOTHÈQUE DE MESSAGES"

    click_on "Envoyer"
    assert_selector '.alert-danger li',text: "À doit être rempli(e)"
    assert_selector '.alert-danger li',text: "Objet doit être rempli(e)"
    assert_selector '.alert-danger li',text: "Contenu de l'email doit être rempli(e)"
  end

  # test "Should create email" do
  #   page.find(".circle-add").click
  #   assert_selector "h4",text: "NOUVELLE ACTION :"
  #   sleep 1
  #
  #   page.find("label[data-target='#tab-email']").click
  #   sleep 1
  #   # assert_selector ".email-title", text: "BIBLIOTHÈQUE DE MESSAGES"
  #
  #   # byebug
  #
  #   execute_script('$("#timeline_email_timeline_type_id_5").click()')
  #   fill_in "timeline_email[to]", with: "test"
  #   fill_in "timeline_email[subject]", with: "test"
  #   fill_in "timeline_email[body]", with: "test"
  #   # byebug
  #
  #   click_on "Envoyer"
  #   sleep 2
  #   assert_selector 'span.text-bolder',text: "#{Goxygene::TimelineType.find(6).label} -"
  #   assert_selector 'span',text: "#{Date.today.strftime("%d/%m/%Y")}"
  # end

  test "Should create note" do
    page.find(".circle-add").click
    assert_selector "h4",text: "NOUVELLE ACTION :"
    sleep 1

    page.find("label[data-target='#tab-memo']").click
    sleep 1
    assert_selector "label",text: "Date"
    fill_in "communication[subject]", with: "test"

    click_on "Ajouter"
    assert_selector 'span.text-bolder',text: "#{Goxygene::TimelineType.find(10).label} -"
    assert_selector 'span',text: "#{Date.today.strftime("%d/%m/%Y")}"
  end

  test "Should show error message when create alert" do
    page.find(".circle-add").click
    assert_selector "h4",text: "NOUVELLE ACTION :"
    sleep 1

    page.find("label[data-target='#tab-alert']").click
    sleep 1
    assert_selector "label",text: "Date"

    click_on "Ajouter"
    assert_selector '.alert-danger li',text: "Date doit être rempli(e)"
  end

  test "Should create alert" do
    page.find(".circle-add").click
    assert_selector "h4",text: "NOUVELLE ACTION :"
    sleep 1

    page.find("label[data-target='#tab-alert']").click
    sleep 1
    assert_selector "label",text: "Date"
    fill_in "communication[subject]", with: "test"
    fill_in "communication[date]", with: "#{Date.today.strftime("%d/%m/%Y")}"

    click_on "Ajouter"
    assert_selector 'span.text-bolder',text: "#{Goxygene::TimelineType.find(9).label} -"
    assert_selector 'span',text: "#{Date.today.strftime("%d/%m/%Y")}"
  end
end
