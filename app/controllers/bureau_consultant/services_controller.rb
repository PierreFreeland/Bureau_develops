module BureauConsultant
  class ServicesController < BureauConsultant::ApplicationController
    before_action :require_consultant!
    before_action :forbid_porteo_consultants!
    before_action :prepare_ransack_search
    before_action :required_search_params, only: :search

    def index
      @solution_numbers = load_cms_pages.pluck(:solution_number)
    end

    def search
      @cms_pages = @q.result(distinct: true)
    end

    def all
      @cms_pages = load_groupped_cms_pages
    end

    def show
      @cms_pages = load_groupped_cms_pages
      @cms_page = load_cms_pages.find_by(slug: params[:id]) || load_cms_pages.find_by(solution_number: params[:id].upcase)
      @page_content = @cms_page.body_content_with_template
      @service_email = FichesServices::ServiceEmail.new
    end

    private

    def load_cms_pages
      FichesServices::Cms::Page.publish.only_profile_for_role('consultant')
    end

    def load_groupped_cms_pages
      cms_pages = load_cms_pages
      { a: cms_pages.solution_group('a'),
        b: cms_pages.solution_group('b'),
        c: cms_pages.solution_group('c'),
        d: cms_pages.solution_group('d'),
        e: cms_pages.solution_group('e') }
    end

    def prepare_ransack_search
      @q = load_cms_pages.ransack(params[:q])
    end

    def required_search_params
      redirect_to services_path unless @q.category_name_or_solution_number_or_solution_name_cont
    end
  end
end
