require "application_system_test_case"
require "goxygene_set_up"

class EstablishmentTimelinesTest < GoxygeneSetUp
  setup do
    visit goxygene.establishment_timelines_path(Goxygene::Establishment.last)
  end

  test "Should change status" do
    assert_selector ".dashboard-top-prospect h4", text: Goxygene::Establishment.last.name
    find("a[href='/goxygene/establishments/#{Goxygene::Establishment.last.id}/active']").click
    assert_selector "h4.modal-title",text: "STATUT"
    sleep 1
    find("img.toggleImg").click
    fill_in "timeline_comment", with: "test"
    click_on "Valider"
    sleep 2
    assert_selector "a[href='/goxygene/establishments/#{Goxygene::Establishment.last.id}/active'] div", "Inactif"
  end

  test "Should redirect to bussiness contracts and consultants" do
    find(".dashboard-top-prospect a[href='/goxygene/establishments/#{Goxygene::Establishment.last.id}/business_contracts']").click
    assert_selector "h4",text: "CONTRATS COMMERCIAUX"

    find(".dashboard-top-prospect a[href='/goxygene/establishments/#{Goxygene::Establishment.last.id}/consultants']").click
    assert_selector "h4", text: "CONSULTANTS"
  end

  test "Should show key details" do
    assert_selector ".info-box" do
      assert_selector "div",text: "Nom : #{Goxygene::Establishment.last.name}"
      assert_selector "div",text: "Raison sociale : #{Goxygene::Establishment.last.company.corporate_name}"
      assert_selector "div",text: "SIRET : #{Goxygene::Establishment.last.siret}"
      assert_selector "div",text: "TVA intracommunautaire : #{Goxygene::Establishment.last.company&.vat_number}"
      assert_selector "div",text: "Identifiant G-Oxygène : #{Goxygene::Establishment.last.id}"
      assert_selector "div",text: "Secteur d’activité principal : #{Goxygene::Establishment.last.line_of_business&.label}"
    end
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
    fill_in "communication[subject]", with: "test skype"

    click_on "Ajouter"
    assert_selector 'span.text-bolder',text: "#{Goxygene::TimelineType.find(16).label} -"
    assert_selector 'span',text: ": test skype"
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
    fill_in "communication[subject]", with: "test call"

    click_on "Ajouter"
    assert_selector 'span.text-bolder',text: "#{Goxygene::TimelineType.find(3).label} -"
    assert_selector 'span',text: ": test call"
    assert_selector 'span',text: "#{Date.today.strftime("%d/%m/%Y")}"
  end


  test "Should create note" do
    page.find(".circle-add").click
    assert_selector "h4",text: "NOUVELLE ACTION :"
    sleep 1

    page.find("label[data-target='#tab-memo']").click
    sleep 1
    assert_selector "label",text: "Date"
    fill_in "communication[subject]", with: "test note"

    click_on "Ajouter"
    assert_selector 'span.text-bolder',text: "#{Goxygene::TimelineType.find(10).label} -"
    assert_selector 'span',text: ": test note"
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
    fill_in "communication[subject]", with: "test alert"
    fill_in "communication[date]", with: "#{Date.today.strftime("%d/%m/%Y")}"

    click_on "Ajouter"
    assert_selector 'span.text-bolder',text: "#{Goxygene::TimelineType.find(9).label} -"
    assert_selector 'span',text: ": test alert"
    assert_selector 'span',text: "#{Date.today.strftime("%d/%m/%Y")}"
  end
end