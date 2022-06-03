require 'bureau_consultant/advance_presenter'

module BureauConsultant
  class AdvancesController < BureauConsultant::ApplicationController
    before_action :require_consultant!
    before_action :load_advances, only: %i{ export history }

    def new
      @advance = current_consultant.wage_advances.new
      @max_advance = current_consultant.cumuls.estimate_max_advance < 0 ? 0.0 : current_consultant.cumuls.estimate_max_advance
    end

    def create
      @advance = current_consultant.wage_advances.new(advance_params)
      @advance.context = 'bureau'
      @advance.wage_advance_status = :itg_editing

      if @advance.save
        redirect_to history_advances_path
      else
        render :new
      end
    end

    def history
    end

    def export
      render xlsx: 'export' , filename: 'export_advances'
    end

    private

    def advance_params
      params.require(:wage_advance).permit(:amount, :correspondant_comment)
    end

    def load_advances
      prepare_date_search_params(:date_gteq, :date_lteq)

      @q = current_consultant.wage_advances.ransack(params[:q])
      @advances = AdvancePresenter.collection(result_for(@q), view_context)
    end
  end
end
