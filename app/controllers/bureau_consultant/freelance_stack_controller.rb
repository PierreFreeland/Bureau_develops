# frozen_string_literal: true

class BureauConsultant::FreelanceStackController < BureauConsultant::ApplicationController
  def redirect
    url = current_consultant.generate_freelance_stack_url

    redirect_to url
  end

  def show; end
end
