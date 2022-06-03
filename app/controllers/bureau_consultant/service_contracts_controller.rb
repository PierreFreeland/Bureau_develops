module BureauConsultant

  # TODO : check if this controller can be removed
  class ServiceContractsController < ApplicationController
    def index

    end

    def new
      @service_contract = ServiceContractPresenter.new(
        current_consultant.commercial_contracts.new,
        view_context
      )
    end

  end
end
