require "application_system_test_case"
require "goxygene_set_up"

class EstablishmentRemindersTest < GoxygeneSetUp
  setup do
    visit goxygene.establishment_reminders_path(Goxygene::Establishment.last)
    assert_selector "h4", text: "RAPPELS"
  end

  test "Should show filter" do
    click_on 'Filtres'
    fill_in "q[date_gteq]", with: "#{Date.today.strftime("%d/%m/%Y")}"
    click_on 'Rechercher'

    result = []
    all(".list-table tbody tr").each do |tr|
      if ("#{Date.today.strftime("%d/%m/%Y")}").include?(tr.all("td")[0].text.to_date)
        result << true
      else
        result << false
      end
    end
    assert !result.include?(false)
    # assert_selector "td", text: "#{Date.today.strftime("%d/%m/%Y")}"
  end

  test "Should change status to done and create skype" do
    all('.fa-pencil').first.click()
    assert_selector ".modal h4", text: "ALERTE :"

    page.find("label[data-target='#tab-skype']").click
    sleep 1
    assert_selector "label", text: "Date"
    page.find("label[for=communication_timeline_type_id_16]").click
    sleep 1
    page.find("label[for=communication_status_done]").click
    sleep 1

    click_on "Ajouter"

    assert_selector "td", text: "Terminé normalement"
  end

  test "Should change status to cancelled and create call" do
    all('.fa-pencil').first.click()
    assert_selector ".modal h4", text: "ALERTE :"

    select "Annulé", from: "timeline_item_status"

    page.find("label[data-target='#tab-call']").click
    sleep 1
    assert_selector "label", text: "Date"

    page.find("label[for=communication_timeline_type_id_3]").click
    sleep 1

    page.find("label[for=communication_status_done]").click
    sleep 1

    click_on "Ajouter"

    assert_selector "td", text: "Annulé"
  end

  test "Should change status to delayed and create sms" do
    all('.fa-pencil').first.click()
    assert_selector ".modal h4", text: "ALERTE :"

    select "Reporté", from: "timeline_item_status"

    page.find("label[data-target='#tab-sms']").click
    sleep 1
    assert_selector ".email-title", text: "BIBLIOTHÈQUE DE MESSAGES"

    fill_in "timeline_sms[from]", with: "test"
    fill_in "timeline_sms[to]", with: "test"
    fill_in "timeline_sms[body]", with: "test"
    # byebug
    sleep 1
    click_on "Envoyer"

    assert_selector "td", text: "Reporté"
  end

  test "Should change status to phone not picked up and create email" do
    all('.fa-pencil').first.click()
    assert_selector ".modal h4", text: "ALERTE :"

    select "N'a pas décroché", from: "timeline_item_status"

    page.find("label[data-target='#tab-email']").click
    sleep 1
    assert_selector ".email-title", text: "BIBLIOTHÈQUE DE MESSAGES"

    fill_in "timeline_email[to]", with: "test"
    fill_in "timeline_email[subject]", with: "test"
    fill_in "timeline_email[body]", with: "test"
    # byebug
    sleep 1

    click_on "Envoyer"

    assert_selector "td", text: "N'a pas décroché"
  end

  test "Should change status to done and create note" do
    all('.fa-pencil').first.click()
    assert_selector ".modal h4", text: "ALERTE :"

    page.find("label[data-target='#tab-memo']").click
    sleep 1
    assert_selector "label", text: "Date"
    fill_in "communication[subject]", with: "test"

    click_on "Ajouter"

    assert_selector "td", text: "Terminé normalement"
  end

end