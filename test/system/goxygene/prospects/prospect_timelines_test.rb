require "application_system_test_case"
require "goxygene_set_up"

class ProspectTimelinesTest < GoxygeneSetUp
  setup do
    # Rails.cache.clear
    visit goxygene.prospect_timelines_path(Goxygene::ProspectingDatum.find(5030))
  end

  test "Should show details in header and show phone call modal" do
    assert_selector ".dashboard-top h4", text: Goxygene::ProspectingDatum.find(5030).consultant.individual.full_name
    assert_selector ".dashboard-top div", text: [Goxygene::ProspectingDatum.find(5030).consultant.contact_datum.email, Goxygene::ProspectingDatum.find(5030).consultant.contact_datum.mobile_phone].join_without_blank(' - ')

    click_on "Appel"
    sleep 1
    assert_selector "h4.modal-title", text: "NOUVELLE ACTION :"
    assert_selector "label.active[data-target='#tab-call']"
  end

  test "Should change potential to c1" do
    find("a[href='/goxygene/prospects/#{Goxygene::ProspectingDatum.find(5030).id}/potential/new']").click
    sleep 1
    assert_selector "h4.modal-title", text: "MODIFIER POTENTIEL"
    select "Prestataire", from: "prospecting_datum_potential_skill"
    select "Faible", from: "prospecting_datum_potential_relevance"
    select "En cours", from: "prospecting_datum_potential_nearness"
    click_on "Enregistrer"
    sleep 1
    assert_selector ".badge-custom.badge-green", text: "C1"
  end

  test "Should change potential to c2" do
    find("a[href='/goxygene/prospects/#{Goxygene::ProspectingDatum.find(5030).id}/potential/new']").click
    sleep 1
    assert_selector "h4.modal-title", text: "MODIFIER POTENTIEL"
    select "Prestataire", from: "prospecting_datum_potential_skill"
    select "Bonne", from: "prospecting_datum_potential_relevance"
    select "Non", from: "prospecting_datum_potential_nearness"
    click_on "Enregistrer"
    sleep 1
    assert_selector ".badge-custom.badge-pink",text: "C2"
  end

  test "Should change potential to c3" do
    find("a[href='/goxygene/prospects/#{Goxygene::ProspectingDatum.find(5030).id}/potential/new']").click
    sleep 1
    assert_selector "h4.modal-title",text: "MODIFIER POTENTIEL"
    select "Prestataire", from: "prospecting_datum_potential_skill"
    select "Sporadique", from: "prospecting_datum_potential_relevance"
    select "Non", from: "prospecting_datum_potential_nearness"
    click_on "Enregistrer"
    sleep 1
    assert_selector ".badge-custom.badge-red",text: "C3"
  end

  test "Should change status" do
    find("a[href='/goxygene/prospects/#{Goxygene::ProspectingDatum.find(5030).id}/statuses/new']").click
    assert_selector "h4.modal-title",text: "MODIFIER STATUT"
    select "Qualifié", from: "prospecting_datum_prospect_status"
    click_on "Enregistrer"
    sleep 2
    assert_selector "a[href='/goxygene/prospects/#{Goxygene::ProspectingDatum.find(5030).id}/statuses/new'] span",text: "ACTIF - Qualifié"
  end

  test "Should save key details" do
    fill_in "prospecting_datum_consultant_attributes_itg_margin", with: "10"
    find("#prospecting_datum_consultant_attributes_granted_expenses", visible: false).set(true)
    find("input[data-url='/goxygene/prospects/#{Goxygene::ProspectingDatum.find(5030).id}/data/toggle_prospect_passport']", visible: false).set(true)

    find("input[data-url='/goxygene/prospects/#{Goxygene::ProspectingDatum.find(5030).id}/toggle_mail_contact']", visible: false).set(true)
    find("input[data-url='/goxygene/prospects/#{Goxygene::ProspectingDatum.find(5030).id}/toggle_mail_notification']", visible: false).set(true)
    find("input[data-url='/goxygene/prospects/#{Goxygene::ProspectingDatum.find(5030).id}/toggle_sms_notification']", visible: false).set(true)
    find("input[data-url='/goxygene/prospects/#{Goxygene::ProspectingDatum.find(5030).id}/toggle_contact_information_visiblity']", visible: false).set(true)
    page.execute_script('location.reload();')
    sleep 1
    assert_selector "#prospecting_datum_consultant_attributes_itg_margin[value='10.0']"
    assert_equal true, page.find("#prospecting_datum_consultant_attributes_granted_expenses", visible: false).checked?
    assert_equal true, page.find("input[data-url='/goxygene/prospects/#{Goxygene::ProspectingDatum.find(5030).id}/data/toggle_prospect_passport']", visible: false).checked?
    assert_equal true, page.find("input[data-url='/goxygene/prospects/#{Goxygene::ProspectingDatum.find(5030).id}/toggle_mail_contact']", visible: false).checked?
    assert_equal true, page.find("input[data-url='/goxygene/prospects/#{Goxygene::ProspectingDatum.find(5030).id}/toggle_mail_notification']", visible: false).checked?
    assert_equal true, page.find("input[data-url='/goxygene/prospects/#{Goxygene::ProspectingDatum.find(5030).id}/toggle_sms_notification']", visible: false).checked?
    assert_equal true, page.find("input[data-url='/goxygene/prospects/#{Goxygene::ProspectingDatum.find(5030).id}/toggle_contact_information_visiblity']", visible: false).checked?
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
    assert_selector 'span.text-bolder', text: "#{Goxygene::TimelineType.find(9).label} -"
    assert_selector 'span', "#{Date.today.strftime("%d/%m/%Y")}"
  end
end