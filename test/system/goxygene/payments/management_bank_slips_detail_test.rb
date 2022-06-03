require "application_system_test_case"
require "goxygene_set_up"

class ManagementBankSlipsDetailTest < GoxygeneSetUp

  test "Should redirect to slip detail when click customer payment" do
    visit goxygene.managements_bank_slip_path(Goxygene::CustomerPaymentSlip.first)
    page.all('tr')[1].click
    assert_selector "h4", "Modifier le règlement"
  end

  test "Should redirect to consultant page" do
    visit goxygene.managements_bank_slip_path(Goxygene::CustomerPaymentSlip.first)
    within ".clickable" do
      all('td')[0].click
    end
    assert_selector "h4", "LES INFOS CLÉS"
  end
end