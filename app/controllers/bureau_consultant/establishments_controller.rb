# frozen_string_literal: true

module BureauConsultant
  class EstablishmentsController < BureauConsultant::ApplicationController
    before_action :require_consultant!

    def search
      head(:not_found) && return if Manageo.key.blank?

      if !params[:name].blank?
        manageo_search_by_name
      elsif !params[:siret].blank?
        manageo_search_by_siret
      end
    rescue Manageo::NotFound
      head :not_found
    end

    def show
      head :not_found if params[:id].blank? || (params[:id].delete("^0-9").length != 14)

      establishment = Goxygene::Establishment.find_by(siret: params[:id].delete("^0-9"))

      if establishment
        render json: {
          siret: establishment.siret,
          name: establishment.name
        }
      else
        head :not_found
      end
    end

    def set_active
      head :not_found if params[:siret].blank? || (params[:siret].delete("^0-9").length != 14)

      establishment = Goxygene::Establishment.find_by(siret: params[:siret].delete("^0-9"))
      establishment.reactivate_from = params[:reactivate_from]
      establishment.update(active: true)
    end

    private

    def manageo_search_by_name
      establishments = Manageo::Company.search term: params[:name], size: 25

      render json: establishments["liste"].map { |e| { siret: e["siret"], name: e["enseigne"], description: e["nomen"], city: e["libcom"] } }
    end

    def manageo_search_by_siret
      siret = params[:siret].delete("^0-9")

      siren = siret[0..8]
      nic   = siret[9..-1].gsub(/^0*/, "")

      establishments = Manageo::Company.establishments siren: siren
      establishment = establishments.select { |e| e.actif == 1 && e.nic.to_s == nic }.first

      raise Manageo::NotFound unless establishment

      if establishment.ville =~ /^[0-9]/ && establishment.codePostal.blank?
        r, zip, city = establishment.ville.match(/([0-9]+) (.*)/).to_a
      else
        city = establishment.ville
        zip  = establishment.codePostal
      end

      render json: {
        name: establishment.raisonSociale,
        address: establishment.adresse,
        zip_code: zip,
        city: city,
        country_id: 1
      }
    end
  end
end
