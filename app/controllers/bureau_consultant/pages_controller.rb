module BureauConsultant
  class PagesController < BureauConsultant::ApplicationController
    before_action :require_consultant!

    def my_relation
    end

    def rules
      @convention_collective = Goxygene::Documentation.find(130)
      @anex1 = Goxygene::Documentation.find(131)
      @anex2 = Goxygene::Documentation.find(132)
      @anex3 = Goxygene::Documentation.find(133)
      @note_explicative = Goxygene::Documentation.find(160)
      @taux_transfo = Goxygene::Documentation.find(164)
    end
  end
end
