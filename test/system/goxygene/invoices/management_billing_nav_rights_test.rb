require "application_system_test_case"
require "goxygene_set_up"

class ManagementBillingNavRightsTest < GoxygeneSetUp

  test "Should redirect to management billings details from management billings details link" do
    visit goxygene.managements_billing_details_path(Goxygene::CustomerBill.last)
    within ".inscription-menus" do
      all('li')[0].click
    end
    assert_selector 'h4', 'DÉTAILS'
  end

  test "Should redirect to management billings invoice payments from management billings details link" do
    visit goxygene.managements_billing_details_path(Goxygene::CustomerBill.last)
    within ".inscription-menus" do
      all('li')[1].click
    end
    assert_selector 'h4', 'RÈGLEMENTS'
  end

  test "Should redirect to management billings divisions from management billings details link" do
    visit goxygene.managements_billing_details_path(Goxygene::CustomerBill.last)
    within ".inscription-menus" do
      all('li')[2].click
    end
    assert_selector 'h4', 'RÉPARTITION'
  end

  test "Should redirect to management billings accountings details from management billings details link" do
    visit goxygene.managements_billing_details_path(Goxygene::CustomerBill.last)
    within ".inscription-menus" do
      all('li')[3].click
    end
    assert_selector 'h4', 'COMPTABILITÉ'
  end

  test "Should redirect to management billings documents from management billings details link" do
    visit goxygene.managements_billing_details_path(Goxygene::CustomerBill.last)
    within ".inscription-menus" do
      all('li')[4].click
    end
    assert_selector 'h4', 'DOCS JOINTS'
  end

end