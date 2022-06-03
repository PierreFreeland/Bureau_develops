module BureauConsultant
  class CitiesController < BureauConsultant::ApplicationController
    before_action :require_consultant!

    def load_zipcode
      @zip_codes = Goxygene::ZipCode
                    .type_family_or_cedex
                    .only_active
                    .where("zip_code LIKE ?", "#{params[:zip_code]}%")
                    .map {|z| {
                      id: z.id,
                      zip_code: z.zip_code,
                      zip_code_id: z.id,
                      text: z.zip_code_and_city,
                      city_name: z.city_label
                    }}

      render json: { results: @zip_codes }
    end
  end
end
