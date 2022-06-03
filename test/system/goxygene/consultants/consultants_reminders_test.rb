require "application_system_test_case"
require "goxygene_set_up"

class ConsultantsRemindersTest < GoxygeneSetUp

  setup do
    visit goxygene.consultants_reminders_path
  end

  test "Should redirect to consultant reminders" do
    assert_selector "h4", "DEMANDES DE RAPPEL ET ALERTES"
  end

  test "Should redirect to consultant timeline" do
    all(".list-table tbody tr").first.click
    assert_selector "h4", "TIMELINE"
  end

  test "Should redirect back to Conseiller de gestion from consultant reminders" do
    click_on "Retour"
    assert_selector "h4", "LES CHIFFRES #{Goxygene::Parameter.value_for_group}"
  end

  test "Should create new call timeline item from consultant reminders" do
    execute_script('$(".rounded-icons .fa-phone")[0].click()')
    sleep 1
    execute_script('$("#communication_timeline_type_id_3").click()')
    execute_script('$("#communication_status_done").click()')
    fill_in "communication_subject", with: "Test create call"
    click_on "Ajouter"
    assert (has_selector?(".fa-phone") && has_selector?("span", "Test create update"))
  end

  test "Should create new skype timeline item" do
    execute_script('$(".rounded-icons .fa-phone")[0].click()')
    sleep 1
    execute_script('$("#skype").click()')
    execute_script('$("#communication_timeline_type_id_16").click()')
    execute_script('$("#communication_status_done").click()')
    fill_in "communication_subject", with: "Test create skype"
    click_on "Ajouter"
    assert (has_selector?(".fa-skype") && has_selector?("span", "Test create skype"))
  end

  test "Should create new alert timeline item" do
    execute_script('$(".rounded-icons .fa-phone")[0].click()')
    sleep 1
    execute_script('$("#alerte").click()')
    sleep 2
    fill_in "communication_subject", with: "Test create alert"
    fill_in "communication_date", with: "#{Date.today.strftime("%d/%m/%Y")}"
    click_on "Ajouter"
    sleep 1
    assert (has_selector?(".fa-exclamation-triangle") && has_selector?("span", "Test create alert"))
  end

  test "Should update timeline acknowledge" do
    before = all(".list-table tbody tr").size
    execute_script('$(".fa-check")[0].click()')
    sleep 1
    assert_equal before - 1, all(".list-table tbody tr").size
  end

  test "Should filter by consultant name" do
    find(".fa-filter").click
    sleep 1
    all(".selection-counter")[1].click
    sleep 1
    selected_consultant = all(".select2-results__option")[1].text
    all(".select2-results__option")[1].click
    execute_script('$("input[value=\"Rechercher\"]").click()')

    result = []
    all(".list-table tbody tr").each do |tr|
      if selected_consultant.include?(tr.all("td")[4].text)
        result << true
      else
        result << false
      end
    end
    assert !result.include?(false)
  end
end

