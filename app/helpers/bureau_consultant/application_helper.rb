module BureauConsultant
  module ApplicationHelper
    include FontAwesome::Rails::IconHelper
    include ItgPresenter

    def impersonating?
      true_cas_authentication != current_cas_authentication
    end

    def truncate_5_lines(string_data)
      string_data.truncate(350, omission: '...')
    end

    def truncate_2_lines(string_data)
      string_data.truncate(70, omission: '...')
    end

    def truncate_tab_label(string_data, chars: 15)
      string_data.to_s.truncate(chars, omission: '')
    end

    def tab_label_popover(label, chars: 15)
      if label.to_s.length > chars
        raw "data-toggle=\"popover\"
            data-trigger=\"hover\"
            data-placement=\"auto top\"
            data-content=\"#{label}\""
      end
    end

    def set_datetime_format(datetime)
      datetime&.to_date.strftime("%d/%m/%Y") if datetime.present?
    end

    def set_month_format(datetime)
      Date.strptime(datetime.strftime('%m/%d/%Y'), '%m/%d/%Y')&.strftime('%m/%Y') if datetime.present?
    end

    def set_month_fr_format(datetime)
      Date.strptime(datetime.strftime('%m/%d/%Y'), '%m/%d/%Y').strftime('%d/%m/%Y') if datetime.present?
    end

    def get_day_from_rss(stringtime)
      stringtime.strftime('%d')
    end

    def get_month_from_rss(stringtime)
      abbr_month_name = I18n.t("date.abbr_month_names")[stringtime.strftime('%m').to_i].capitalize

      remove_dot_month_name(abbr_month_name)
    end

    def remove_dot_month_name(month_name)
      month_name.gsub(".", "")
    end

    def get_year_from_rss(stringtime)
      stringtime.strftime('%Y')
    end

    def date_with_elisied_prefix(date, format: :month_year)
      localized = I18n.l(date, format: :month_year)

      if localized.start_with?(*%w{a e i o u y})
        "d'#{localized}"
      else
        "de #{localized}"
      end
    end

    def display_logo_image_path(consultant)
      company_logo_id = consultant.itg_establishment_id || (Goxygene.is_freeteam? ? 1001 : 1 )
      "bureau_consultant/company_logos/#{company_logo_id}"
    end

    def display_logo_image_path_by_itg_establishment_id(itg_establishment_id)
      company_logo_id = itg_establishment_id || 1
      "bureau_consultant/company_logos/#{company_logo_id}"
    end

    def display_datetime(datetime)
      datetime ? I18n.l(datetime) : ""
    end

    def display_currency(amount, opts = {})
      number_to_currency(amount || 0, opts)
    end

    def vat_rates_options
      Goxygene::Vat.active.for_bureau.all.collect do |c|
        [
            c.label,
            c.id,
            {'data-vat-rate' => c.rate}
        ]
      end
    end

    def vat_rates_except_aucune_options
      Goxygene::Vat.active.for_bureau.where.not(id: 1).collect do |c|
        [
            c.label,
            c.id,
            {'data-vat-rate' => c.rate}
        ]
      end
    end

    def training_target_options
      Goxygene::TrainingTarget.active.all.collect do |c|
        [
            c.label,
            c.id
        ]
      end
    end

    def training_domains_options
      Goxygene::TrainingDomain.active.all.collect do |c|
        [
            c.label,
            c.id
        ]
      end
    end

    def countries_options
      Goxygene::Country.all.collect {|c| [c.label, c.id]}
    end

    def builders_risk_insurances_options
      Goxygene::ConstructionInsuranceRate.all.collect {|c| [c.label, c.id]}
    end

    def contact_types_options
      Goxygene::ContactType.for_bureau.collect {|c| [c.label, c.id]}
    end

    def contact_roles_options
      Goxygene::ContactRole.all.collect {|c| [c.label, c.id]}
    end

    def currencies_options
      Goxygene::Currency.only_active.order(:id).map {|p| [p.name, p.id]}
    end

    def payment_methods_options
      Goxygene::PaymentType.where(active: true).all.map {|p|
        [
            p.label,
            p.id
        ]
      }
    end

    def billing_mode_options
      BureauConsultant::BillingMode.all.collect {|c| ["Montant #{c.label}", c.id]}
    end

    def activity_type_options(activity = nil)
      can_have_unemployment_activities = (activity.nil? || activity&.office_activity_report_expenses&.empty?) \
        && statement_of_activities_request&.can_have_unemployment_activities? \
        && (activity&.date && !activity.date.saturday? && !activity.date.sunday?)
      can_have_formation_activities = current_consultant.c_pro_type?
      can_have_full_time_activities = current_consultant.full_time? && !activity&.date&.saturday? && !activity&.date&.sunday?
      options = Goxygene::ActivityType.options
      options.delete_if { |row| row[1] == 8 } unless can_have_unemployment_activities
      options.delete_if { |row| row[1] == 10 } unless can_have_formation_activities
      options.delete_if { |row| row[1].in? [9, 11, 12, 13, 14]} unless can_have_full_time_activities
      options.delete_if { |row| row[1] == 15 }
      options
    end

    def user_id_event
      if session[:userIdLoggedIn].nil?
        session[:userIdLoggedIn] = Time.now
        'login'
      else
        if current_consultant.google_analytics_id_created
          'creation'
        else
          ''
        end
      end
    end

    def set_default_field_zipcode_select2(zip_code, contact_city)
      "#{zip_code} - #{contact_city}"
    end

    def check_integer_number?(number)
      number.to_f % 1 == 0
    end

    def convert_to_france_number(number)
      if check_integer_number?(number)
        number_with_delimiter(number.to_i).html_safe # to_i for remove .00
      else
        number = number_with_precision(number, precision: 2, separator: '.')
        number_with_delimiter(number).html_safe
      end
    end

    def display_france_number_percentage(amount)
      "#{convert_to_france_number(amount)}%"
    end
  end
end
