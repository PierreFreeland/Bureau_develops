require "application_system_test_case"
require "goxygene_set_up"

class ClientsRemindersTest < GoxygeneSetUp

  setup do
    visit goxygene.client_reminders_path(Goxygene::Customer.find(17080))
  end

  test "Should can filter" do
    click_on "Filtres"
    click_on "Rechercher"
    assert_selector "li.active a", text:  "RAPPELS"
  end

  test "Should go to client timelines when click a one of list" do
    find('.list-table tbody tr:first-child td:first-child').click
    sleep 1
    assert_selector "li.active a", text:  "TIMELINE"
  end

  test "Should show a contact edit form and choose the skype tab" do
    find('.list-table tbody tr:first-child a[href*="edit"]', visible: false).click
    sleep 3
    find('label[data-href*="timeline_skypes"]').click
    sleep 3
    assert_selector ".modal h4", text:  "ALERTE"
    assert_selector ".modal .active span", text:  "Skype"
  end

  test "Should show a contact edit form and choose the appel tab" do
    find('.list-table tbody tr:first-child a[href*="edit"]', visible: false).click
    sleep 3
    find('label[data-href*="timeline_calls"]').click
    sleep 3
    assert_selector ".modal h4", text:  "ALERTE"
    assert_selector ".modal .active span", text:  "Appel"
  end

  test "Should show a contact edit form and choose the sms tab" do
    find('.list-table tbody tr:first-child a[href*="edit"]', visible: false).click
    sleep 3
    find('label[data-href*="timeline_sms"]').click
    sleep 3
    assert_selector ".modal h4", text:  "ALERTE"
    assert_selector ".modal .active span", text:  "SMS"
  end

  test "Should show a contact edit form and choose the email tab" do
    find('.list-table tbody tr:first-child a[href*="edit"]', visible: false).click
    sleep 3
    find('label[data-href*="timeline_emails"]').click
    sleep 3
    assert_selector ".modal h4", text:  "ALERTE"
    assert_selector ".modal .active span", text:  "Email"
  end

  test "Should show a contact edit form and choose the memo tab" do
    find('.list-table tbody tr:first-child a[href*="edit"]', visible: false).click
    sleep 3
    find('label[data-href*="timeline_memos"]').click
    sleep 3
    assert_selector ".modal h4", text:  "ALERTE"
    assert_selector ".modal .active span", text:  "MÉMO"
  end
end
