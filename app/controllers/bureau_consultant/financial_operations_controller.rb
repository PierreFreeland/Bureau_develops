module BureauConsultant
  class FinancialOperationsController < BureauConsultant::ApplicationController
  	before_action :require_consultant!
  end
end