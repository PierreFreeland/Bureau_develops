# frozen_string_literal: true

require "test_helper"

describe Api::ContactsController do
  describe "Not authenticated using a token" do
    it "should reject with not authorized" do
      post "/api/contacts"
      assert_response :unauthorized
    end

    it "should create a new timeline item" do
      post "/api/contacts/newtimeline", params: { "email": "Liane.Bahringer_13894@consulting-itg.fr", "contact_reason_id": 1 }
      assert_response :unauthorized
    end
  end

  describe "Authenticated using a token" do
    let(:authorization_header) do
      client = Doorkeeper::Application.create(
        user_id: Goxygene::Employee.first.id,
        redirect_uri: "urn:ietf:wg:oauth:2.0:oob",
        scopes: "public write",
        name: "test"
      )
      scopes = Doorkeeper::OAuth::Scopes.from_string("public")
      creator = Doorkeeper::OAuth::ClientCredentials::Creator.new
      token = creator.call(client, scopes)

      { "Authorization": "Bearer #{token.token}" }
    end

    let(:employee) { Goxygene::Employee.first }

    let(:consultant_activity) do
      Goxygene::ConsultantActivity.create!(
        active: true,
        employee_id: employee.id,
        created_by: employee.id,
        updated_by: employee.id,
        label: "testing"
      )
    end

    let(:valid_params) do
      {
        "contact": {
          "civility": "M",
          "firstName": "Jean",
          "lastName": "Dupont",
          "email": "jean@dupont.com",
          "zipcode": "59000",
          "phone": "0621212123",
          "comment": "foo bar",
          "contact_reason_id": 10,
          "contact_origin_id": "string",
          "contact_origin": "string",
          "speciality_id": consultant_activity.id,
          "is_missioneo": "string",
          "web_form": "string",
          "form_type": "string",
          "referring_website": "string",
          "arrival_url": "string",
          "ask_question": "string",
          "sex": "string"
        }
      }
    end

    let(:missing_records) do
      Goxygene::TimelineType.create!(
        kind: "prospecting_event",
        active: true,
        hidden_in_timeline: false,
        hidden_in_notifications: true,
        label: "Création de la fiche",
        created_by: employee.id,
        updated_by: employee.id
      )

      Goxygene::TimelineType.create!(
        kind: "communication",
        active: true,
        hidden_in_timeline: false,
        hidden_in_notifications: false,
        label: "Message depuis internet",
        created_by: employee.id,
        updated_by: employee.id
      )

      Goxygene::CommunicationMotive.create!(
        id: 10,
        timeline_context: "prospect_folow_up",
        active: true,
        label: "Demande RDV Individuel",
        show_on_web_sites: true,
        sort_order: 3,
        created_by: employee.id,
        updated_by: employee.id
      )
    end

    it "should error out because of missing contact param" do
      assert_raises ActionController::ParameterMissing do
        post "/api/contacts", params: {}, headers: authorization_header
      end
    end

    it "should create a new contact" do
      missing_records

      assert_difference "Goxygene::Consultant.count" do
        post "/api/contacts", params: valid_params, headers: authorization_header
      end

      json = JSON.parse(response.body)
      assert json["id"].present?
      assert_equal "DUPONT Jean", json["name"]
      assert_equal "0033621212123", json["phone"]
    end

    it "set contact city name when valid zipcode is provided" do
      missing_records

      assert_difference "Goxygene::Consultant.count" do
        post "/api/contacts", params: valid_params, headers: authorization_header
      end

      assert_equal "LILLE", Goxygene::ContactDatum.last.city
    end

    it "should create a timeline item for a consultant creation / update" do
      missing_records

      assert_difference "Goxygene::TimelineItem.count" do
        post "/api/contacts", params: valid_params, headers: authorization_header
      end
    end

    it "should set the employee from the timeline item" do
      missing_records

      post "/api/contacts", params: valid_params, headers: authorization_header

      assert_equal employee.id, Goxygene::TimelineItem.last.employee_id
    end

    it "should update existing contact" do
      missing_records

      post "/api/contacts", params: valid_params, headers: authorization_header

      assert_no_difference "Goxygene::Consultant.count" do
        post "/api/contacts",
             params: valid_params.deep_merge("contact": { "phone": "0675232323" }),
             headers: authorization_header
      end

      json = JSON.parse(response.body)
      assert json["id"].present?
      assert_equal "0033675232323", json["phone"]
    end

    it "should not create a new contact if email case changed" do
      missing_records

      post "/api/contacts", params: valid_params, headers: authorization_header

      assert_no_difference "Goxygene::Consultant.count" do
        post "/api/contacts",
             params: valid_params.deep_merge("contact": { "email": "JEAN@dupont.com" }),
             headers: authorization_header
      end
    end

    it "should not create a new contact if email is provided and exists but name changed" do
      missing_records

      post "/api/contacts", params: valid_params, headers: authorization_header

      assert_no_difference "Goxygene::Consultant.count" do
        post "/api/contacts",
             params: valid_params.deep_merge("contact": { "email": "JEAN@dupont.com", "firstName": "new_one" }),
             headers: authorization_header
      end
    end

    it "should assign a random advisor" do
      missing_records

      post "/api/contacts", params: valid_params.deep_merge("contact": { "zipcode": nil, "speciality_id": nil }), headers: authorization_header
      assert_equal 304, Goxygene::Consultant.last.advisor_employee_id
    end

    it "should assign advisor linked to given zipcode" do
      missing_records

      post "/api/contacts", params: valid_params.deep_merge("contact": { "zipcode": "59300", "speciality_id": nil }), headers: authorization_header
      assert_equal 138, Goxygene::Consultant.last.advisor_employee_id
    end

    it "should create a new timeline item" do
      assert_difference "Goxygene::TimelineItem.count" do
        post "/api/contacts/newtimeline", params: { "email": "Liane.Bahringer_13894@consulting-itg.fr", "contact_reason_id": 1 }, headers: authorization_header
      end

      json = JSON.parse(response.body)
      assert_equal 13_894, json["id"]
      assert_equal "Bahringer Liane", json["name"]
      assert_equal "16075968373", json["phone"]
    end
  end
end
