require "application_system_test_case"
require "goxygene_set_up"

class ManagementBillingPaymentsTest < GoxygeneSetUp

  test "Should redirect to create credit note page from payment" do
    visit goxygene.managements_billing_payments_path(Goxygene::CustomerBill.last)
    click_on "Création d’avoir"
    assert_selector 'h4', 'CRÉATION D’UN AVOIR CLIENT'
  end

end