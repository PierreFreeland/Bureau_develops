module BureauConsultant
  class BillingPointsController < BureauConsultant::ApplicationController
    before_action :require_consultant!

    def index
      billing_points = current_consultant.establishments_from_contacts

      render json: billing_points.map { |billing_point| billing_point_attributes(billing_point) }
    end

    def show
      billing_point = current_consultant.establishments_from_contacts.find(params[:id])

      render json: billing_point_attributes(billing_point)
    end

    private

    def billing_point_attributes(billing_point)
      {
        id:            billing_point.id,
        name:          billing_point.name,
        vat_number:    billing_point.company.vat_number,
        siret:         billing_point.siret,
        address_line1: billing_point.contact_datum.address_1,
        address_line2: billing_point.contact_datum.address_2,
        address_line3: billing_point.contact_datum.address_3,
        zipcode_city:  billing_point.contact_datum.city,
        city:          billing_point.contact_datum.city,
        zip_code:      billing_point.contact_datum.zip_code,
        zip_code_id:   billing_point.contact_datum.zip_code_id,
        country_id:    billing_point.contact_datum.country_id,
        tel_number:    billing_point.contact_datum.phone,
        email:         billing_point.contact_datum.email,
        establishment_contacts: billing_point.establishment_contacts.for_consultant(current_consultant).active.collect { |c|
                                  c.slice(%i{
                                    id
                                    last_name first_name
                                    contact_type_id contact_role_id
                                    country_id zip_code zip_code_id city
                                    address_1 address_2 address_3
                                    phone email
                                  })
                                }
        }
    end

  end
end
