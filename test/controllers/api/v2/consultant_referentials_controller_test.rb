require "test_helper"
module Api
  module V2
    describe ConsultantReferentialsController do
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

      describe "Get consultant referential data" do
        describe "Authenticated using a token" do
          it "should respond with bad request" do
            get "/api/v2/consultant_referential", headers: authorization_header
            assert_response :bad_request
          end

          it "should respond with a JSON" do
            itg_company = ItgCompany.first
            get "/api/v2/consultant_referential",
                headers: authorization_header,
                params: { itg_company: itg_company.id }

            assert_response :ok

            json = JSON.parse(response.body)

            expected_data = {
                "insee_categories" => PayrollInseeCategory.all,
                "categories" => PayrollCategory.by_itg_company_id(itg_company.id),
                "civilities" => Civility.all,
                "jobs" => PayrollJobType.by_itg_company_id(itg_company.id),
                "document_formats" => DocumentFormat.all,
                "languages" => Language.all,
                "payment_types" => PaymentType.all,
                "study_levels" => StudyLevel.all,
                "vehicle_taxe_weights" => VehicleTaxeWeight.all,
                "language_levels" => LanguageLevel.all,
                "training_profiles" => TrainingProfile.all,
                "consultant_deactivation_reasons" => ConsultantDeactivationReason.all,
                "prospect_deactivation_reasons" => ProspectDeactivationReason.all,
                "employment_end_reasons" => EmploymentEndReason.all,
                "consultant_activities" => ConsultantActivity.all,
                "consultant_skills" => ConsultantSkill.all,
                "family_statuses" => FamilyStatus.all,
                "vehicle_energies" => VehicleEnergy.all,
                "payroll_contract_types" => PayrollContractType.all,
                "document_kinds" => DocumentKind.show_on_bureau_prospect,
                "document_types" => DocumentType.all,
                "payroll_time_units" => PayrollTimeUnit.all,
                "vehicle_types" => VehicleType.all,
                "contact_mean_enum" => EstablishmentContact.contact_mean.options.to_hash_options,
                "prospect_potential_skill_enum" => ProspectingDatum.potential_skill.options.to_hash_options,
                "prospect_potential_relevance_enum" => ProspectingDatum.potential_relevance.options.to_hash_options,
                "prospect_potential_nearness_enum" => ProspectingDatum.potential_nearness.options.to_hash_options,
                "consultant_origin_enum" => Consultant.consultant_origin.options.to_hash_options,
                "consultant_status_enum" => Consultant.consultant_status.options.to_hash_options,
                "prospect_status_enum" => ProspectingDatum.prospect_status.options.to_hash_options,
                "employment_trial_period_enum" => EmploymentTrialPeriod.period_type.options.to_hash_options,
                "customer_type_enum" => [{:value=> Goxygene::Establishment.name, :label=> Goxygene::Establishment.name}, {:value=> Goxygene::Establishment.name, :label=> Goxygene::Consultant.name}]
            }

            assert_equal expected_data.size, json.size

            expected_data.each do |key, value|
              assert_equal value.size, json[key]&.size, "Not equal at #{key}"
            end
          end
        end
      end
    end
  end
end
