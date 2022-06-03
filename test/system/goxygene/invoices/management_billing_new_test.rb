require "application_system_test_case"
require "goxygene_set_up"

class ManagementBillingNewTest < GoxygeneSetUp

  # test "Should open consultant select2 input box" do
  #   visit goxygene.new_managements_billing_path
  #   all('.select2')[0].click
  #   assert_selector '.select2-search__field'
  # end
  #
  # test "Should open client select2 input box" do
  #   visit goxygene.new_managements_billing_path
  #   all('.select2')[1].click
  #   assert_selector '.select2-search__field'
  # end

  test "Should create the invoice" do
    visit goxygene.new_managements_billing_path

    ################# FORMULAIRE DE CRÉATION D’UNE FACTURE #################
    fill_in 'delay', with: 1

    # fill consultant select2
    all('.select2')[0].click
    find(:css, "input[class$='select2-search__field']").set("Gutkowski")
    sleep(1)
    all('.select2-results__option')[0].click
    
    #fill client select2
    all('.select2')[1].click
    find(:css, "input[class$='select2-search__field']").set("lyanla")
    sleep(1)
    all('.select2-results__option')[0].click

    sleep(1)
    #select establishment contact
    within ".customer-bill-billing-contract" do
      all('option')[1].click
    end
    ####################################################################

    ########################## DETAIL BOX #############################
    #select customer bill detail type
    within ".bill-detail-type" do
      all('option')[2].click
    end

    #fill label
    fill_in 'customer_bill[customer_bill_details_attributes][0][label]', with: 'test'

    #fill amount
    fill_in 'customer_bill[customer_bill_details_attributes][0][amount]', with: 100
    ###################################################################

    click_on 'Enregistrer'
    assert_selector 'h4', 'DÉTAILS'
  end
end