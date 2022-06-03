require "application_system_test_case"
require "goxygene_set_up"

class ProspectDocumentsTest < GoxygeneSetUp

  setup do
    visit goxygene.prospect_documents_path(Goxygene::ProspectingDatum.find(5030))
  end

  test"Should redirect to prospect documents page" do
    assert_selector "h4", "DOCUMENTS"
  end

  test "Should success to download file" do
    before = page.driver.browser.window_handles
    all('a[target="_blank"]').first.click
    sleep 2
    after = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(after.last)
    assert_equal before.size + 1, after.size
  end

  test "Should success to remove file" do
    before = all(".fa-minus").count
    accept_alert do
      all('a[data-method="delete"]').first.click
    end
    sleep 2
    assert_equal before - 1, all(".fa-minus").count
  end

end
