# frozen_string_literal: true

module BureauConsultant
  module InvoiceRequestsHelper
    def establishment_contacts(billing_point, selected = nil)
      contacts = billing_point.establishment_contacts.active.for_consultant(current_consultant).map do |contact|
        [
          "#{contact.first_name} #{contact.last_name}",
          contact.id,
          { 'data-id': contact.id },
          { 'data-last_name': contact.last_name },
          { 'data-first_name': contact.first_name },
          { 'data-contact_type_id': contact.contact_type_id },
          { 'data-contact_role_id': contact.contact_role_id },
          { 'data-country_id': contact.country_id },
          { 'data-zip_code': contact.zip_code },
          { 'data-zip_code_id': contact.zip_code_id },
          { 'data-city': contact.city },
          { 'data-address': contact.address },
          { 'data-phone': contact.phone },
          { 'data-email': contact.email }
        ]
      end

      options_for_select contacts, selected: selected
    end

    def business_contracts(establishment_id)
      current_consultant.business_contracts.
        joins(:business_contract_versions).
        where(establishment_id: establishment_id).
        distinct
    end

    def business_contract_options(establishment_id: nil, contract_id: nil)
      return [] if establishment_id.nil?

      options_for_select(
        business_contracts(establishment_id).map { 
        |contract| ["#{contract.id} - #{contract.business_contract_versions.last.customer_contract_reference} - Du #{contract.begining_date&.strftime('%d/%m/%Y')} au #{contract.ending_date&.strftime('%d/%m/%Y')}", contract.id] },
        {
          selected: contract_id.to_i,
          disabled: "select"
        }
      )
    end

    def invoice_request_total_line(label:, amount:)
      content_tag(:div, class: "row") do
        content_tag(:div, class: "col-md-9") { label } +
          content_tag(:div, class: "col-md-2 align-center") { amount }
      end
    end

    def invoice_request_horizontal_line
      content_tag(:div, class: "row") do
        content_tag(:div, class: "col-md-1")  {} +
          content_tag(:div, class: "col-md-11 horizontal_line bg-white") { content_tag :hr }
      end
    end

    def select_for_invoice_request_line_type(invoice_request_line = nil, disabled: false)
      selected = if invoice_request_line.nil?
        "select"
      elsif invoice_request_line.detail_type.nil?
        if invoice_request_line.label.blank?
          "break"
        else
          "comment"
        end
      elsif invoice_request_line.is_line_jump?
        "break"
      elsif invoice_request_line.is_comment?
        "comment"
      elsif invoice_request_line.is_expense?
        "expense"
      elsif invoice_request_line.is_fee?
        "fee"
                  end

      select_tag "invoice_request_line[invoice_request_line_type]",
                 options_for_select([
                                      ["Sélectionnez", "select", { 'data-disable-amount': true }, { 'data-disable-label': true }, { 'data-clear-amount': false }, { 'data-clear-label': false }],
                                      ["Honoraire", "fee", { 'data-disable-amount': false }, { 'data-disable-label': false }, { 'data-clear-amount': false }, { 'data-clear-label': false }, { 'data-placeholder-amount': "HT" }],
                                      ["Frais",  "expense", { 'data-disable-amount': false }, { 'data-disable-label': false }, { 'data-clear-amount': false }, { 'data-clear-label': false }, { 'data-placeholder-amount': "TTC" }],
                                      ["Commentaire", "comment", { 'data-disable-amount': true }, { 'data-disable-label': false }, { 'data-clear-amount': true }, { 'data-clear-label': false }],
                                      ["Saut de ligne", "break", { 'data-disable-amount': true }, { 'data-disable-label': true }, { 'data-clear-amount': true }, { 'data-clear-label': true }]
                                    ],
                                    selected: selected,
                                    disabled: "select"),
                 class: "form-control",
                 disabled: disabled
    end

    def label_input_for_invoice_request_line_for_mobile(line_object = nil)
      css_classes = "invoice_request_line_label form-control"
      css_classes += " has-error" if line_object && line_object.errors[:label].any?

      text_field_tag "invoice_request_line[label]",
                     line_object.try(:label),
                     class: css_classes,
                     maxlength: 110,
                     placeholder: "Renseignez le libellé pour ajouter du contenu à votre facture"
    end

    def label_input_for_invoice_request_line(line_object = nil)
      css_classes = "invoice_request_line_label form-control"
      css_classes += " has-error" if line_object && line_object.errors[:label].any?

      text_area_tag "invoice_request_line[label]",
                    line_object.try(:label),
                    rows: 1,
                    cols: 88,
                    class: css_classes,
                    maxlength: 110,
                    placeholder: "Renseignez le libellé pour ajouter du contenu à votre facture"
    end

    def amount_input_for_invoice_request_line(line_object = nil)
      css_classes = "invoice_request_line_amount form-control"
      css_classes += " has-error" if line_object && line_object.errors[:amount].any?

      text_field_tag "invoice_request_line[amount]",
                     line_object.try(:has_amount?) ? line_object.amount : nil,
                     class: css_classes
    end

    def address_for_invoice(invoice_request)
      if invoice_request.establishment.persisted?
        raw([invoice_request.establishment_contact&.contact_datum&.address_1,
         invoice_request.establishment_contact&.contact_datum&.address_2,
         invoice_request.establishment_contact&.contact_datum&.address_3,
         "#{invoice_request.establishment_contact&.contact_datum&.zip_code} #{invoice_request.establishment_contact&.contact_datum&.city} #{invoice_request.establishment_contact&.contact_datum&.country&.label}"].join_without_blank('<br/>'))
      else
        raw([invoice_request.contact_address_1,
             invoice_request.contact_address_2,
             invoice_request.contact_address_3,
             "#{invoice_request.contact_zip_code} #{invoice_request.contact_city} #{invoice_request.contact_country.label}"].join_without_blank("<br/>"))
      end
    end

    def contact_name_for_invoice(invoice_request)
      if invoice_request.establishment.persisted? && invoice_request&.establishment_contact&.individual
        invoice_request.establishment_contact.individual.full_name
      else
        "#{invoice_request.contact_first_name} #{invoice_request.contact_last_name}"
      end
    end

    def establishment_name_for_invoice(invoice_request)
      if invoice_request.establishment.persisted?
        invoice_request.establishment.name
      else
        invoice_request.establishment_name
      end
    end

    def vat_text(vat_id, vat_rate, number_format)
      vat_rate_text = ""
      vat_rate_text = number_with_precision(vat_rate, number_format)

      case vat_id
      when 3
        "Livraison intracommunautaire exonérée – Art 283-2 du CGI #{vat_rate_text}"
      when 4
        "Exportation exonérée - Art 283-2 du CGI #{vat_rate_text}"
      when 5
        "Article 296.1 b du CGI #{vat_rate_text}"
      when 6
        "TVA non applicable - article 261.4.4 a du CGI #{vat_rate_text}"
      when 7
        "Article 278-0 bis du CGI #{vat_rate_text}"
      when 11
        "Article 279-0 bis du CGI #{vat_rate_text}"
      else
        vat_rate_text
      end
    end
  end
end
