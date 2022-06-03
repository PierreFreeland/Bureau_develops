var formSubmitted = false;

$(document).ready(function() {

  if (window.location.pathname.includes('/invoice_requests/') && performance.navigation.type == 2) {
    location.reload();
  }

  $('.chosen-select-billings').on('change', function() {
    $('#loading').modal('show');
    var companyID = $(this).val();

    if (companyID) {
      $.ajax({ url: '/bureau_consultant/billing_points/' + companyID })
        .done(function(data) {
          set_value_invoice_request(data);
          get_commercial_contracts(companyID);
          set_contact_list_invoice_request(data);
          set_value_contact_invoice_request({});

          $('#loading').modal('hide');
        })
        .fail(function() {
          $('#loading').modal('hide');
          alert("erreur ne peut pas obtenir les données du serveur");
        });
    } else {
      $('#office_customer_bill_business_contract_id').html('');
      set_value_invoice_request('');
      set_contact_list_invoice_request('');
      set_value_contact_invoice_request({});

      $('#loading').modal('hide');
    }

  });

  if (jQuery.isEmptyObject($('select#office_customer_bill_establishment_id').val())) {
    set_value_invoice_request('', false);
  } else {
    $('#office_customer_bill_establishment_zip_code').attr('disabled', true).attr('readonly', true);
  }
  set_value_contact_invoice_request($('select.establishment_contact option:selected').data(), false)

  $('select.establishment_contact').on('change', function() {
    set_value_contact_invoice_request($('select.establishment_contact option:selected').data());
  });

  $('input#office_customer_bill_copy_contact_address_from_establishment').on('change', function() {
    if (!!$('#office_customer_bill_establishment_contact_id option:selected').data('id')) {
      return;
    }

    attrs = '#office_customer_bill_contact_country_id, #office_customer_bill_contact_address_1,' +
      '#office_customer_bill_contact_address_2, #office_customer_bill_contact_address_3,' +
      '#office_customer_bill_contact_zip_code_id, #office_customer_bill_contact_city,' +
      '#office_customer_bill_contact_zip_code'

    if ($('input#office_customer_bill_copy_contact_address_from_establishment').is(':checked')) {

      attrs.split(',').forEach(function(attr) {
        $(attr).val($(attr.replace('contact', 'establishment')).val()).change().focusout();
      });

      if ($('#office_customer_bill_establishment_zip_code_id').val() == '') {
        zipcode_fields_switch('not france', 2);
        $('div.other-country2 #office_customer_bill_contact_zip_code').val($('div.other-country1 #office_customer_bill_establishment_zip_code').val()).change().focusout();
      } else {
        $('#select2-office_customer_bill_contact_zip_code-container').html($('#select2-office_customer_bill_establishment_zip_code-container').html());
      }


    } else {

      $(attrs).val('');

      $('#office_customer_bill_contact_zip_code').find('option').remove();
      $('#select2-office_customer_bill_contact_zip_code-container').html('');
      $('#office_customer_bill_contact_zip_code').val('');

    }
  });

  // Search by siret stuff

  $('#office_customer_bill_establishment_siret').on('change', function() {
    if ($('#office_customer_bill_establishment_id').val() == '' && $('#office_customer_bill_establishment_siret').val().length >= 9) {
      // search siret in oxygene

      let siret = $('#office_customer_bill_establishment_siret').val()

      $('#loading').modal('show');

      $.ajax({ url: '/bureau_consultant/establishments/' + siret })
        .done(function(data) {
          $("#loading").removeClass("in");
          $(".modal-backdrop").remove();
          $("#loading").hide();
          //$('#loading').modal('hide'); // conflit avec le modal(hide) de loadDefaultCountryVatRate qui est appelé apres avoir la recherche par siret (quand on select un nom) dans la creation de facture esapce consultant

          $('#siret_existing span.siret').html(data.siret);
          $('#siret_existing span.name').html(data.name);

          $('#siret_existing').modal('show');

        })
        .fail(function() {
          $("#loading").removeClass("in");
          $(".modal-backdrop").remove();
          $("#loading").hide();
          //$('#loading').modal('hide'); // conflit avec le modal(hide) de loadDefaultCountryVatRate qui est appelé apres avoir la recherche par siret (quand on select un nom) dans la creation de facture esapce consultant
          $('form.invoice_request button#search_by_siret').show();
        });
    } else {
      $('form.invoice_request button#search_by_siret').hide();
    }
  });

  $('#siret_existing.invoice_request button.siret-no').click(function(e) {
    $('#office_customer_bill_establishment_siret').val('').change().focusout();
  });

  $('#siret_existing.invoice_request button.siret-yes').click(function(e) {
    let siret = $('#office_customer_bill_establishment_siret').val();

    $.ajax({
      url: '/bureau_consultant/establishments/set_active',
      type: 'PATCH',
      data: { siret: siret, reactivate_from: 'customer_bill' }
    });

    window.location.href = rootPathByVarient() + "/bureau_consultant/invoice_requests/new_from_siret?siret=" + siret;
  });

  $('form.invoice_request button#search_by_siret').click(function(e) {
    $('#loading').modal('show');

    let siret = $('#office_customer_bill_establishment_siret').val();

    $.ajax({
      url: '/bureau_consultant/establishments/search',
      data: {
        siret: siret
      }
    })
      .done(function(data) {
        $('#office_customer_bill_establishment_name').val(data.name).change().focusout().attr('readonly', true);
        $('#office_customer_bill_establishment_country_id').val(data.country_id).change().focusout().attr('readonly', true);
        $('#office_customer_bill_establishment_address_1').change().focusout().attr('readonly', true);
        $('#office_customer_bill_establishment_address_2').val(data.address).change().focusout().attr('readonly', true);
        $('#office_customer_bill_establishment_address_3').change().focusout().attr('readonly', true);

        zipcode_fields_switch('not france', 1);
        $('div.other-country1 #office_customer_bill_establishment_zip_code').val(data.zip_code).change().focusout();
        $('div.other-country1 #office_customer_bill_establishment_zip_code').change().focusout().attr('readonly', true);

        $('#office_customer_bill_establishment_city').val(data.city).change().focusout().attr('readonly', true);

        $('form.invoice_request button#search_by_siret').hide();
        $('#loading').modal('hide');
      })
      .fail(function() {
        $('form.invoice_request button#search_by_siret').hide();
        $('#loading').modal('hide');
        alert("Le client n’a pas été trouvé. Merci de saisir les informations");
      });

    return false;
  });

  // Search by name+address stuff

  $('#office_customer_bill_establishment_name, #office_customer_bill_establishment_city, #office_customer_bill_establishment_zip_code').on('change', function() {
    if ($('#office_customer_bill_establishment_siret').val() == ''
      && $('#office_customer_bill_establishment_id').val() == ''
      && $('#office_customer_bill_establishment_name').val() != '') {
      $('form.invoice_request button#search_by_name').show();
    } else {
      $('form.invoice_request button#search_by_name').hide();
    }
  });

  $('form.invoice_request button#search_by_name').click(function(e) {
    $('#loading').modal('show');

    // var siret = $('#office_customer_bill_establishment_siret').val();

    $.ajax({
      url: '/bureau_consultant/establishments/search',
      data: {
        name: $('#office_customer_bill_establishment_name').val(),
        address: $('#office_customer_bill_establishment_address_2').val(),
        zip_code: $('#office_customer_bill_establishment_zip_code').val(),
        city: $('#office_customer_bill_establishment_city').val(),
        country: $('#office_customer_bill_establishment_country_id option:selected').text()
      }
    })
      .done(function(data) {
        set_establishments_list(data);

        $('#establishments_block').show();

        $('form.invoice_request button#search_by_name').hide();
        $('#loading').modal('hide');
      })
      .fail(function() {
        $('form.invoice_request button#search_by_name').hide();
        $('#loading').modal('hide');
        alert("Le client n’a pas été trouvé. Merci de saisir les informations");
      });

    return false;
  });

  $('#establishments').on('change', function() {
    $('#office_customer_bill_establishment_siret').val($('#establishments option:selected').data('siret')).change().focusout().attr('readonly', true);

    $('button#search_by_siret').click();

    $('#establishments_block').hide();
  });

  function set_value_invoice_request(data, clear = true) {
    attrs = '#office_customer_bill_establishment_vat_number, #office_customer_bill_establishment_name,' +
      '#office_customer_bill_establishment_siret, #office_customer_bill_establishment_zip_code,' +
      '#office_customer_bill_establishment_city, #office_customer_bill_establishment_country_id,' +
      '#office_customer_bill_establishment_phone, #office_customer_bill_email,' +
      '#office_customer_bill_establishment_address_1, #office_customer_bill_establishment_address_2,' +
      '#office_customer_bill_establishment_address_3';

    if (data) {
      $('#office_customer_bill_establishment_id').val(data.id);
      $('#office_customer_bill_establishment_siret').val(data.siret).change().focusout();
      $('#office_customer_bill_establishment_vat_number').val(data.vat_number).change().focusout();
      $('#office_customer_bill_establishment_name').val(data.name).change().focusout();
      $('#office_customer_bill_establishment_country_id').val(data.country_id).change().focusout();
      $('#office_customer_bill_establishment_address_1').val(data.address_line1).change().focusout();
      $('#office_customer_bill_establishment_address_2').val(data.address_line2).change().focusout();
      $('#office_customer_bill_establishment_address_3').val(data.address_line3).change().focusout();

      if (data.zip_code_id == null) {
        zipcode_fields_switch('not france', 1);
        $('div.other-country1 #office_customer_bill_establishment_zip_code').val(data.zip_code).change().focusout();
        $('#office_customer_bill_establishment_zip_code_id').val(null).change().focusout();
      } else {
        $('#office_customer_bill_establishment_zip_code').attr('disabled', true);
        $('#office_customer_bill_establishment_zip_code').append('<option value="' + data.zip_code + '">' + data.zip_code + ' - ' + data.city + '</option>').val(data.zip_code);
        $('#office_customer_bill_establishment_zip_code').attr('data-selected-text', data.zip_code + ' - ' + data.city)
        $('#select2-office_customer_bill_establishment_zip_code-container').html(data.zip_code + ' - ' + data.city);

        $('#office_customer_bill_establishment_zip_code_id').val(data.zip_code_id).change().focusout();
      }


      $('#office_customer_bill_establishment_city').val(data.city).change().focusout();
      $('#office_customer_bill_establishment_phone').val(data.tel_number).change().focusout();
      $(attrs).attr('readonly', true);
    }
    else {
      $(attrs).attr('readonly', false);

      if (clear) {
        $(attrs).val('');

        $('#office_customer_bill_establishment_zip_code').find('option').remove();
        $('#select2-office_customer_bill_establishment_zip_code-container').html('');
        $('#office_customer_bill_establishment_zip_code').val('');
      }

      $('#office_customer_bill_establishment_zip_code').attr('disabled', false);
      call_zipcode_selecte2()
    }
  }

  function set_value_contact_invoice_request(data, clear = true) {
    attrs = '#office_customer_bill_contact_last_name, #office_customer_bill_contact_first_name,' +
      '#office_customer_bill_contact_contact_type_id, #office_customer_bill_contact_contact_role_id,' +
      '#office_customer_bill_contact_country_id, #office_customer_bill_contact_address_1,' +
      '#office_customer_bill_contact_address_2, #office_customer_bill_contact_address_3,' +
      '#office_customer_bill_contact_zip_code, #office_customer_bill_contact_city,' +
      '#office_customer_bill_contact_phone, #office_customer_bill_contact_email,' +
      '#office_customer_bill_contact_zip_code_id'

    if (!jQuery.isEmptyObject(data)) {
      $('input#office_customer_bill_copy_contact_address_from_establishment').parents('div.form-group').hide();

      Object.getOwnPropertyNames(data).forEach(function(attr) {
        if (attr != 'zip_code') {
          $('#office_customer_bill_contact_' + attr).val(data[attr]).change().focusout();
        }
      });

      $('#office_customer_bill_contact_zip_code').attr('disabled', true);
      $('#office_customer_bill_contact_zip_code').append('<option value="' + data.zip_code + '">' + data.zip_code + '</option>').val(data.zip_code);
      $('#select2-office_customer_bill_contact_zip_code-container').html(data.zip_code);

      $('#office_customer_bill_contact_zip_code').attr('disabled', false);

      $('#office_customer_bill_contact_city').val(data['city']).change().focusout();
      $('#office_customer_bill_contact_zip_code_id').val(data['zip_code_id']).change().focusout();

    } else {
      $('input#office_customer_bill_copy_contact_address_from_establishment').parents('div.form-group').show();
      $('input#office_customer_bill_copy_contact_address_from_establishment').prop('checked', false);
      $(attrs).attr('readonly', false);

      if (clear) {
        $(attrs).val('');

        $('#office_customer_bill_contact_zip_code').find('option').remove();
        $('#select2-office_customer_bill_contact_zip_code-container').html('');
        $('#office_customer_bill_contact_zip_code').val('');
        $('#office_customer_bill_contact_zip_code_id').val('');
      }

      $('#office_business_contract_establishment_zip_code').attr('disabled', false);
    }
  }

  function set_contact_list_invoice_request(data) {
    $('#office_customer_bill_establishment_contact_id').empty();
    $('#office_customer_bill_establishment_contact_id').append('<option value="">Nouveau</option>');

    if (data) {
      data.establishment_contacts.forEach(function(entry) {

        let attributes = [];
        Object.getOwnPropertyNames(entry).forEach(function(attr) {
          attributes.push(`data-${attr}="${entry[attr]}"`);
        })

        $('#office_customer_bill_establishment_contact_id').append(
          `<option value=${entry.id} ${attributes.join(' ')}>${entry.first_name} ${entry.last_name}</option>`
        );
      });
    }
  }

  function get_commercial_contracts(client_id) {
    $.ajax({ url: '/bureau_consultant/billing_points/' + client_id + '/commercial_contracts' })
      .done(function(commercial_contract_data) {

        if (commercial_contract_data.length == 0)
          option = '<option value=""></option>'
        else
          option = '<option value="">Sélectionner un contrat</option>'

        for (var i = 0; i < commercial_contract_data.length; i++) {
          option += '<option value=' + commercial_contract_data[i].id + '>' + commercial_contract_data[i].id
          if (commercial_contract_data[i].customer_contract_reference !== null) {
            option += ' - ' + commercial_contract_data[i].customer_contract_reference
          }
          option += ' - Du ' + commercial_contract_data[i].begin_date + ' au ' + commercial_contract_data[i].end_date + '</option>'
        }

        $('#office_customer_bill_business_contract_id').html(option);
      })
  }

  if ($('#office_customer_bill_establishment_country_id').length && !$('#office_customer_bill_vat_id option[selected]').length) {
    set_zip_code_requirement_for_invoice();
    loadDefaultCountryVatRate($("#office_customer_bill_establishment_country_id").val(), $('#office_customer_bill_vat_id'));
  }

  $('#office_customer_bill_establishment_country_id').change(function() {
    if ($('#office_customer_bill_establishment_country_id').length) {
      set_zip_code_requirement_for_invoice();
      loadDefaultCountryVatRate($("#office_customer_bill_establishment_country_id").val(), $('#office_customer_bill_vat_id'));
    }
  });

  if ($('#office_customer_bill_contact_country_id').length) {
    set_zip_code_requirement_for_invoice();
  }

  $('#office_customer_bill_contact_country_id').change(function() {
    if ($('#office_customer_bill_contact_country_id').length) {
      set_zip_code_requirement_for_invoice();
      loadDefaultCountryVatRate($("#office_customer_bill_establishment_country_id").val(), $('#office_customer_bill_vat_id'));
    }
  });

  $('#invoice_request textarea').each(function() {
    this.setAttribute('style', 'height:' + (this.scrollHeight) + 'px;overflow-y:hidden;');
  }).on('input', function() {
    this.style.height = 'auto';
    this.style.height = (this.scrollHeight) + 'px';
  });

  function set_zip_code_requirement_for_invoice() {
    if ($("#office_customer_bill_establishment_country_id").val() == 1) {
      $('label[for="office_customer_bill_establishment_zip_code"]').addClass('required');
      $('input#office_customer_bill_establishment_zip_code').enableClientSideValidations();
    } else {
      $('label[for="office_customer_bill_establishment_zip_code"]').removeClass('required');
      $('input#office_customer_bill_establishment_zip_code').disableClientSideValidations();
    }

    if ($("#office_customer_bill_contact_country_id").val() == 1) {
      $('label[for="office_customer_bill_contact_zip_code"]').addClass('required');
      $('input#office_customer_bill_contact_zip_code').enableClientSideValidations();
    } else {
      $('label[for="office_customer_bill_contact_zip_code"]').removeClass('required');
      $('input#office_customer_bill_contact_zip_code').disableClientSideValidations();
    }
  }

  function apply_invoice_line_type_properties(select_input) {
    var amount_input = $(select_input).parents('.invoice_request_line').find('.invoice_request_line_amount');
    var label_input = $(select_input).parents('.invoice_request_line').find('.invoice_request_line_label');

    var disable_amount = $(select_input).find(':selected').data('disable-amount');
    var disable_label = $(select_input).find(':selected').data('disable-label');

    var placeholder_amount = $(select_input).find(':selected').data('placeholder-amount');

    amount_input.prop('placeholder', placeholder_amount);

    amount_input.prop('disabled', disable_amount);
    label_input.prop('disabled', disable_label);

    if ($(select_input).find(':selected').data('clear-amount')) {
      amount_input.data('old-value', amount_input.val());
      amount_input.val('');
    } else {
      if (amount_input.data('old-value')) {
        amount_input.val(amount_input.data('old-value'));
      }
    }

    if ($(select_input).find(':selected').data('clear-label')) {
      label_input.data('old-value', label_input.val());
      label_input.data('old-placeholder', label_input.prop('placeholder'));
      label_input.val('');
      label_input.prop('placeholder', '')
    } else {
      if (label_input.data('old-value')) {
        label_input.val(label_input.data('old-value'));
      }
      label_input.prop('placeholder', label_input.data('old-placeholder'));
    }
  }

  $('#invoice_request select:enabled').change(function() {
    apply_invoice_line_type_properties(this);
    if ($(this).val()) {
      $(this).parents('.invoice_request_line').find('a.submit').removeClass('disabled');
    }
  });

  if ($('#invoice_request select:enabled').length) {
    $('#invoice_request select:enabled').each(function() {
      apply_invoice_line_type_properties(this);
    })
  }

  $('#invoice_request form.current_line a.submit').click(function() {
    if (formSubmitted) {
      return false;
    }

    if ($(this).parents('.invoice_request_line').find('select').val() != null) {
      formSubmitted = true;

      $(this).closest('form').submit();
    }
    return false;
  });

  $('#invoice_request_line_label').on('input', function() {
    toggle_next_button();
  });

  $('#invoice_request_line_amount').on('input', function() {
    toggle_next_button();
  });

  if ($('#next').length > 0 && $('#invoice_request_line_label').length > 0 && $('#invoice_request_line_amount').length) {
    toggle_next_button();
  }

});

function change_next_button_to_submit() {
  $('#next').html('AJOUTER');
  $('#next').removeClass('btn-rouge');
  $('#next').addClass('btn-orange');
  $('#next').attr('href', '');
  $('#next').attr('onclick', "$('#invoice_request form.current_line').submit(); return false;");
}

function revert_next_button() {
  $('#next').html('SUIVANT');
  $('#next').removeClass('btn-orange');
  $('#next').addClass('btn-rouge');
  $('#next').attr('href', '/bureau_consultant/invoice_requests/synthesis');
  $('#next').attr('onclick', '');
}

function toggle_next_button() {
  if ($('#invoice_request_line_label').val().length > 0 || $('#invoice_request_line_amount').val().length > 0) {
    change_next_button_to_submit();
  } else {
    revert_next_button();
  }
}
