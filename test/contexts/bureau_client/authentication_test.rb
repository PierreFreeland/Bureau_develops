require_relative "bureau_client_test_helper"

class AuthenticationTest < ActiveSupport::BureauClientIntegrationTest
  test "rejected when not logged in" do
    get(
      '/api/v2/client/customer_bills_cumuls',
      params: {
        client_id: goxygene_individuals(:michel).id
      },
    )

    assert_response 401
  end

  test "rejected when using an unknown token" do
    get(
      '/api/v2/client/customer_bills_cumuls',
      params: {
        client_id: goxygene_individuals(:michel).id
      },
      headers: {
        "Authorization": "Bearer foobartoot"
      }
    )

    assert_response 401
  end

  test "rejected when using contact without access" do
    get(
      '/api/v2/client/customer_bills_cumuls',
      params: {
        client_id: goxygene_individuals(:leia).id
      },
      headers: {
        "Authorization": "Bearer #{oauth_access_tokens(:api_tests).token}"
      }
    )

    assert_response 401
  end
end
