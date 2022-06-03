require_relative "bureau_client_test_helper"

class ContactTest < ActiveSupport::BureauClientIntegrationTest
  test "using a basic contact" do
    get(
      "/api/v2/client/contacts/#{goxygene_company_contacts(:jeremy).cas_authentication.email}",
      headers: authorization_header
    )

    expected = {
      "id" => goxygene_company_contacts(:jeremy).id,
      "contact" => {
        "address_1" => "Rue de la ré",
        "address_2" => "Au rez de chaussé",
        "address_3" => "",
        "zip_code" => "69001",
        "city" => "Lyon",
        "country" => "France",
        "phone" => "+33423434565",
        "mobile_phone" => "+33623434565",
        "email" => "jeremy@yopmail.com"
      },
      "individual" => {
        "id" => goxygene_individuals(:jeremy).id,
        "civility" => "oth",
        "first_name" => "jeremy",
        "last_name" => "bartaud"
      },
      "employee" => {
        "id" => goxygene_employees(:santa_claus).id,
        "civility" => "Other",
        "first_name" => "Santa",
        "last_name" => "Claus",
        "phone" => "+33423434565",
        "mobile_phone" => "+33623434565",
        "email" => "santa_claus+no-reply@yopmail.com"
      }
    }


    assert_response :success
    assert_equal expected, JSON.parse(@response.body)
  end

  test "using an unknown email" do
    get(
      "/api/v2/client/contacts/toot@tiit.com",
      headers: authorization_header
    )

    assert_response 404
  end
end
