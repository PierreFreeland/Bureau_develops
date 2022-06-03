require "application_system_test_case"
require "goxygene_set_up"

class ConsultantTimelinesTest < GoxygeneSetUp
  setup do
    visit goxygene.consultant_timelines_path(Goxygene::Consultant.first)
  end

  test "Should show consultant detail in header" do
    assert_selector ".dashboard-top h4",text: "M Beier, Carey"
    assert_selector ".dashboard-top div",text: [Goxygene::Consultant.first.contact_datum.email, Goxygene::Consultant.first.contact_datum.mobile_phone].join_without_blank(' - ')
    assert_selector ".dashboard-top a[href='tel:#{Goxygene::Consultant.first.contact_datum.mobile_phone}']",text: "Appel"
  end

  test "Should change consultant status in header" do
    page.find("a[href='/goxygene/consultants/#{Goxygene::Consultant.first.id}/statuses/new']").click
    sleep 1
    assert_selector "h4",text: "MODIFIER STATUT"
    page.find("label[for='consultant_consultant_status_desactivated_consultant']").click
    sleep 1
    click_on "Enregistrer"
    sleep 1
    assert_selector "a[href='/goxygene/consultants/#{Goxygene::Consultant.first.id}/statuses/new'] span",text: "DÉSACTIVÉ"
  end

  test "Should show key info" do
    assert_selector "div",text: "Entité #{Goxygene::Parameter.value_for_group} : #{Goxygene::Consultant.first.itg_establishment&.itg_company&.root_parent&.corporate_name}"
    assert_selector "div",text: "Conseiller de gestion : #{Goxygene::Consultant.first.correspondant_employee&.individual&.full_name}"
    assert_selector "div",text: "Fonction : #{Goxygene::Consultant.first.payroll_job_type&.label}"
  end

  test "Should update data when click on chechbox" do
    find("input[data-url='/goxygene/consultants/#{Goxygene::Consultant.first.id}/toggle_b2b']", visible: false).set(false)
    find("input[data-url='/goxygene/consultants/#{Goxygene::Consultant.first.id}/toggle_send_payslips_by_email']", visible: false).set(false)
    find("input[data-url='/goxygene/consultants/#{Goxygene::Consultant.first.id}/toggle_mail_contact']", visible: false).set(true)
    find("input[data-url='/goxygene/consultants/#{Goxygene::Consultant.first.id}/toggle_mail_notification']", visible: false).set(true)
    find("input[data-url='/goxygene/consultants/#{Goxygene::Consultant.first.id}/toggle_sms_notification']", visible: false).set(false)
    find("input[data-url='/goxygene/consultants/#{Goxygene::Consultant.first.id}/toggle_contact_information_visiblity']", visible: false).set(false)
    find("input[data-url='/goxygene/consultants/#{Goxygene::Consultant.first.id}/toggle_newsletter_ok']", visible: false).set(false)
    find("input[data-url='/goxygene/consultants/#{Goxygene::Consultant.first.id}/toggle_dont_want_communication']", visible: false).set(true)
    page.execute_script('location.reload();')
    sleep 1
    assert_equal false, page.find("input[data-url='/goxygene/consultants/#{Goxygene::Consultant.first.id}/toggle_b2b']", visible: false).checked?
    assert_equal false, page.find("input[data-url='/goxygene/consultants/#{Goxygene::Consultant.first.id}/toggle_send_payslips_by_email']", visible: false).checked?
    assert_equal true, page.find("input[data-url='/goxygene/consultants/#{Goxygene::Consultant.first.id}/toggle_mail_contact']", visible: false).checked?
    assert_equal true, page.find("input[data-url='/goxygene/consultants/#{Goxygene::Consultant.first.id}/toggle_mail_notification']", visible: false).checked?
    assert_equal false, page.find("input[data-url='/goxygene/consultants/#{Goxygene::Consultant.first.id}/toggle_sms_notification']", visible: false).checked?
    assert_equal false, page.find("input[data-url='/goxygene/consultants/#{Goxygene::Consultant.first.id}/toggle_contact_information_visiblity']", visible: false).checked?
    assert_equal false, page.find("input[data-url='/goxygene/consultants/#{Goxygene::Consultant.first.id}/toggle_newsletter_ok']", visible: false).checked?
    assert_equal true, page.find("input[data-url='/goxygene/consultants/#{Goxygene::Consultant.first.id}/toggle_dont_want_communication']", visible: false).checked?

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

  test "Should create alert and filter" do
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

    fill_in "q[date_gteq]", with: "#{Date.today.strftime("%d/%m/%Y")}"
    sleep 2
    assert_selector 'span',text: "#{Date.today.strftime("%d/%m/%Y")}"
  end
end