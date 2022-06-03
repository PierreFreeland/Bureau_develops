module BureauConsultant
  class SalariesController < BureauConsultant::ApplicationController
    before_action :require_consultant!

    def download
      if salary.document
        redirect_to salary.document.filename.url
      else
        head :not_found
      end
    end

    def download_simplified
      if salary.document_old
        redirect_to salary.document_old.filename.url
      else
        head :not_found
      end
    end

    private

    def salary
      @salary ||= current_consultant.wages.find(params[:salary_id])
    end

  end
end
