require_relative "bureau_client_test_helper"

class CustomerBillsCumulsTest < ActiveSupport::BureauClientIntegrationTest
  test "the world is running correctly" do
    assert true
  end

  test "the fixtures are loaded correctly" do
    assert_not_nil Goxygene::Company.find_by_corporate_name("Big Brother")
  end

  test "the biggest company got all cumuls" do
    get(
      '/api/v2/client/customer_bills_cumuls',
      params: {
        client_id: goxygene_individuals(:michel).id
      },
      headers: authorization_header
    )

    expected = {
      "last_30_days" => 1075.00,
      "between_30_and_60_days" => 85.0,
      "more_than_60_days" => 79.0
    }

    assert_response :success
    assert_equal expected, JSON.parse(@response.body)
  end

  test "the middle company got some cumuls" do
    get(
      '/api/v2/client/customer_bills_cumuls',
      params: {
        client_id: goxygene_individuals(:jeremy).id
      },
      headers: authorization_header
    )

    expected = {
      "last_30_days" => 675.00,
      "between_30_and_60_days" => 85.0,
      "more_than_60_days" => 79.0
    }

    assert_response :success
    assert_equal expected, JSON.parse(@response.body)
  end

  test "the little company got fewer cumuls" do
    get(
      '/api/v2/client/customer_bills_cumuls',
      params: {
        client_id: goxygene_individuals(:luke).id
      },
      headers: authorization_header
    )

    expected = {
      "last_30_days" => 500.00,
      "between_30_and_60_days" => 0.0,
      "more_than_60_days" => 0.0
    }

    assert_response :success
    assert_equal expected, JSON.parse(@response.body)
  end
end
