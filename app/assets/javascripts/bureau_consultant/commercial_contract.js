$(document).ready(function(){
    $(function() {
        /* Bootstrap Datepicker */
        window.set_datepicker = function() {
            $('.datepicker').datepicker({
                format: "dd/mm/yyyy",
                todayBtn: "linked",
                language: "fr",
                todayHighlight: true,
                allowInputToggle: true
            }).on('changeDate', function (ev) {
                $(this).datepicker('hide');
                window.edited = true;
                $(this).change().focusout();
            })
        };
        set_datepicker();
    });


    $('.chosen-select').on('change', function(){
      $('#loading').modal('show');
      var companyID = $(this).val();

      if(companyID) {
          $.ajax({url: '/bureau_consultant/billing_points/' + companyID})
              .done(function (data) {
                  set_value_commercial_contract(data);
                  set_contact_list(data);
                  set_value_contact({});

                  $('#loading').modal('hide');
              })
              .fail(function () {
                  $('#loading').modal('hide');
                  alert("erreur ne peut pas obtenir les données du serveur");
              });
      } else {
          set_value_commercial_contract('');
          set_contact_list('');
          set_value_contact({});

          $('#loading').modal('hide');
      }

    });

    if (jQuery.isEmptyObject($('select#office_business_contract_establishment_id').val())) {
      set_value_commercial_contract('', false);
    } else {
      $('#office_business_contract_establishment_zip_code').attr('disabled', true).attr('readonly', true);
    }
    set_value_contact($('select.establishment_contact option:selected').data(), false)

    $('select.establishment_contact').on('change', function(){
      set_value_contact($('select.establishment_contact option:selected').data());
    });

    $('input#office_business_contract_copy_contact_address_from_establishment').on('change', function(){
      if (!!$('#office_business_contract_establishment_contact_id option:selected').data('id')) {
        return;
      }

      attrs = '#office_business_contract_contact_country_id, #office_business_contract_contact_address_1,' +
              '#office_business_contract_contact_address_2, #office_business_contract_contact_address_3,' +
              '#office_business_contract_contact_zip_code_id, #office_business_contract_contact_city,' +
              '#office_business_contract_contact_zip_code'

      if ($('input#office_business_contract_copy_contact_address_from_establishment').is(':checked')) {

        attrs.split(',').forEach(function (attr){
          $(attr).val($(attr.replace('contact', 'establishment')).val()).change().focusout();
        });

        if ($('#office_business_contract_establishment_zip_code_id').val() == '') {
          zipcode_fields_switch('not france', 2);
          $('div.other-country2 #office_business_contract_contact_zip_code').val($('div.other-country1 #office_business_contract_establishment_zip_code').val()).change().focusout();
        } else {
          $('#select2-office_business_contract_contact_zip_code-container').html($('#select2-office_business_contract_establishment_zip_code-container').html());
        }

      } else {

        $(attrs).val('');

        $('#office_business_contract_contact_zip_code').find('option').remove();
        $('#select2-office_business_contract_contact_zip_code-container').html('');
        $('#office_business_contract_contact_zip_code').val('');

      }
    });

    $('#billing_mode_select').on('change', function(){
        toggle_billing_mode_fields();

        var billing_without_vat = $('#billing-without-vat-input');
        var ordered_days_approx = $('#time-length-approx-input');
        var daily_rate = $('#daily-order-amount-input');
        if($(this).val() === 'fixed_price'){
            billing_without_vat.prop('readonly', false);
            ordered_days_approx.prop('disabled', false);
            daily_rate.prop('disabled', true);
        }else {
            billing_without_vat.prop('readonly', true);
            ordered_days_approx.prop('disabled', true);
            daily_rate.prop('disabled', false);
            calculate_order_amount();
        }
    });

    $('.list-table')
        .on('click', 'th :checkbox', function() {
            check_all = $(this);
            table = check_all.closest('table');
            checkes = table.find('td :checkbox');
            checkes.prop('checked', check_all.prop('checked'));
        })
        .on('click', 'td :checkbox', function() {
            table = $(this).closest('table');
            check_all = table.find('th :checkbox');
            checkes = table.find('td :checkbox');
            checked = checkes.filter(':checked');
            check_all.prop('checked', checkes.length == checked.length);
        });

    // Search by siret stuff

    $('#office_business_contract_establishment_siret').on('change', function(){
      if ($('#office_business_contract_establishment_id').val() == '' && $('#office_business_contract_establishment_siret').val().length >= 9) {
        // search siret in oxygene

        let siret = $('#office_business_contract_establishment_siret').val()

        $('#loading').modal('show');

        $.ajax({ url: '/bureau_consultant/establishments/' + siret })
            .done(function (data) {
              $('#loading').modal('hide');

              $('#siret_existing span.siret').html(data.siret);
              $('#siret_existing span.name').html(data.name);

              $('#siret_existing').modal('show');

            })
            .fail(function () {
              $('#loading').modal('hide');
              $('form.commercial_contract button#search_by_siret, form.office_training_agreement button#search_by_siret').show();
            });

      } else {
        $('form.commercial_contract button#search_by_siret, form.office_training_agreement button#search_by_siret').hide();
      }
    });

    $('#siret_existing.commercial_contract button.siret-no').click(function(e){
      $('#office_business_contract_establishment_siret').val('').change().focusout();
    });

    $('#siret_existing.commercial_contract button.siret-yes').click(function(e){
      let siret = $('#office_business_contract_establishment_siret').val()

      $.ajax({
        url: '/bureau_consultant/establishments/set_active',
        type: 'PATCH',
        data: { siret: siret, reactivate_from: 'business_contract' }
      });

      window.location.href = rootPathByVarient() + "/bureau_consultant/commercial_contracts/new_from_siret?siret=" + siret;
    });

    $('#siret_existing.office_training_agreement button.siret-no').click(function(e){
      $('#office_business_contract_establishment_siret').val('').change().focusout();
    });

    $('#siret_existing.office_training_agreement button.siret-yes').click(function(e){
      let siret = $('#office_business_contract_establishment_siret').val()

      $.ajax({
        url: '/bureau_consultant/establishments/set_active',
        type: 'PATCH',
        data: { siret: siret, reactivate_from: 'business_contract' }
      });

      window.location.href = rootPathByVarient() + "/bureau_consultant/office_training_agreements/new_from_siret?siret=" + siret;
    });

    $('form.commercial_contract button#search_by_siret, form.office_training_agreement button#search_by_siret').click(function(e){
      $('#loading').modal('show');

      var siret = $('#office_business_contract_establishment_siret').val();

      $.ajax({
        url: '/bureau_consultant/establishments/search',
        data: {
          siret: siret
        }
      })
          .done(function (data) {
              $('#office_business_contract_establishment_name').val(data.name).change().focusout().attr('readonly', true);
              $('#office_business_contract_establishment_country_id').val(data.country_id).change().focusout().attr('readonly', true);
              $('#office_business_contract_establishment_address_1').change().focusout().attr('readonly', true);
              $('#office_business_contract_establishment_address_2').val(data.address).change().focusout().attr('readonly', true);
              $('#office_business_contract_establishment_address_3').change().focusout().attr('readonly', true);

              zipcode_fields_switch('not france', 1);
              $('div.other-country1 #office_business_contract_establishment_zip_code').val(data.zip_code).change().focusout();
              $('div.other-country1 #office_business_contract_establishment_zip_code').change().focusout().attr('readonly', true);

              $('#office_business_contract_establishment_city').val(data.city).change().focusout().attr('readonly', true);

              $('form.commercial_contract button#search_by_siret, form.office_training_agreement button#search_by_siret').hide();
              $('#loading').modal('hide');
          })
          .fail(function () {
              $('form.commercial_contract button#search_by_siret, form.office_training_agreement button#search_by_siret').hide();
              $('#loading').modal('hide');
              alert("Le client n’a pas été trouvé. Merci de saisir les informations");
          });

      return false;
    });

    // Search by name+address stuff

    $('#office_business_contract_establishment_name, #office_business_contract_establishment_city, #office_business_contract_establishment_zip_code').on('change', function(){
      if ($('#office_business_contract_establishment_siret').val() == ''
          && $('#office_business_contract_establishment_id').val() == ''
          && $('#office_business_contract_establishment_name').val() != '') {
        $('form.commercial_contract button#search_by_name, form.office_training_agreement button#search_by_name').show();
      } else {
        $('form.commercial_contract button#search_by_name, form.office_training_agreement button#search_by_name').hide();
      }
    });

    $('form.commercial_contract button#search_by_name, form.office_training_agreement button#search_by_name').click(function(e){
      $('#loading').modal('show');

      // var siret = $('#office_business_contract_establishment_siret').val();

      $.ajax({
        url: '/bureau_consultant/establishments/search',
        data: {
          name:     $('#office_business_contract_establishment_name').val(),
          address:  $('#office_business_contract_establishment_address_2').val(),
          zip_code: $('#office_business_contract_establishment_zip_code').val(),
          city:     $('#office_business_contract_establishment_city').val(),
          country:  $('#office_business_contract_establishment_country_id option:selected').text()
        }
        })
          .done(function (data) {
              set_establishments_list(data);

              $('#establishments_block').show();

              $('form.commercial_contract button#search_by_name, form.office_training_agreement button#search_by_name').hide();
              $('#loading').modal('hide');
          })
          .fail(function () {
              $('form.commercial_contract button#search_by_name, form.office_training_agreement button#search_by_name').hide();
              $('#loading').modal('hide');
              alert("Le client n’a pas été trouvé. Merci de saisir les informations");
          });

      return false;
    });

    $('#establishments').on('change', function(){
      $('#office_business_contract_establishment_siret').val($('#establishments option:selected').data('siret')).change().focusout().attr('readonly', true);

      $('form.commercial_contract button#search_by_siret, form.office_training_agreement button#search_by_siret').click();

      $('#establishments_block').hide();
    });



});


function set_value_commercial_contract(data, clear = true) {
  attrs = '#office_business_contract_establishment_vat_number, #office_business_contract_establishment_name,' +
     '#office_business_contract_establishment_siret, #office_business_contract_establishment_zip_code,' +
     '#office_business_contract_establishment_city, #office_business_contract_establishment_country_id,' +
     '#office_business_contract_establishment_phone, #office_business_contract_email,' +
     '#office_business_contract_establishment_address_1, #office_business_contract_establishment_address_2,' +
     '#office_business_contract_establishment_address_3';

   if(data) {
       $('#office_business_contract_establishment_id').val(data.id);
       $('#office_business_contract_establishment_siret').val(data.siret).change().focusout();
       $('#office_business_contract_establishment_vat_number').val(data.vat_number).change().focusout();
       $('#office_business_contract_establishment_name').val(data.name).change().focusout();
       $('#office_business_contract_establishment_country_id').val(data.country_id).change().focusout();
       $('#office_business_contract_establishment_address_1').val(data.address_line1).change().focusout();
       $('#office_business_contract_establishment_address_2').val(data.address_line2).change().focusout();
       $('#office_business_contract_establishment_address_3').val(data.address_line3).change().focusout();

       if (data.zip_code_id == null) {
         zipcode_fields_switch('not france', 1);
         $('div.other-country1 #office_business_contract_establishment_zip_code').val(data.zip_code).change().focusout();
         $('#office_business_contract_establishment_zip_code_id').val(null).change().focusout();
       } else {
         $('#office_business_contract_establishment_zip_code').attr('disabled', true);
         $('#office_business_contract_establishment_zip_code').append('<option value="'+ data.zip_code + '">' + data.zip_code + '</option>').val(data.zip_code);
         $('#select2-office_business_contract_establishment_zip_code-container').html(data.zip_code);

         $('#office_business_contract_establishment_zip_code_id').val(data.zip_code_id).change().focusout();
       }

       $('#office_business_contract_establishment_city').val(data.city).change().focusout();
       $('#office_business_contract_establishment_phone').val(data.tel_number).change().focusout();
       $(attrs).attr('readonly', true);
   }
   else {
      $(attrs).attr('readonly', false);

      if (clear) {
        $(attrs).val('');

        $('#office_business_contract_establishment_zip_code').find('option').remove();
        $('#select2-office_business_contract_establishment_zip_code-container').html('');
        $('#office_business_contract_establishment_zip_code').val('');
      }

      $('#office_business_contract_establishment_zip_code').attr('disabled', false);
      call_zipcode_selecte2()
   }
}

function set_value_contact(data, clear = true) {
  attrs = '#office_business_contract_contact_last_name, #office_business_contract_contact_first_name,' +
      '#office_business_contract_contact_contact_type_id, #office_business_contract_contact_contact_role_id,' +
      '#office_business_contract_contact_country_id, #office_business_contract_contact_address_1,' +
      '#office_business_contract_contact_address_2, #office_business_contract_contact_address_3,' +
      '#office_business_contract_contact_zip_code, #office_business_contract_contact_city,' +
      '#office_business_contract_contact_phone, #office_business_contract_contact_email,' +
      '#office_business_contract_contact_zip_code_id'

  if (!jQuery.isEmptyObject(data)) {
    $('input#office_business_contract_copy_contact_address_from_establishment').parents('div.form-group').hide();

    Object.getOwnPropertyNames(data).forEach(function (attr) {
      if (attr != 'zip_code') {
        $('#office_business_contract_contact_' + attr).val(data[attr]).change().focusout();
      }
    });

    $('#office_business_contract_contact_zip_code').attr('disabled', true);
    $('#office_business_contract_contact_zip_code').append('<option value="'+ data.zip_code + '">' + data.zip_code + '</option>').val(data.zip_code);
    $('#select2-office_business_contract_contact_zip_code-container').html(data.zip_code);

    $('#office_business_contract_contact_zip_code').attr('disabled', false);

    $('#office_business_contract_contact_city').val(data['city']).change().focusout();
    $('#office_business_contract_contact_zip_code_id').val(data['zip_code_id']).change().focusout();

  } else {

    $('input#office_business_contract_copy_contact_address_from_establishment').parents('div.form-group').show();
    $('input#office_business_contract_copy_contact_address_from_establishment').prop('checked', false);
    $(attrs).attr('readonly', false);

    if (clear) {
      $(attrs).val('');

      $('#office_business_contract_contact_zip_code').find('option').remove();
      $('#select2-office_business_contract_contact_zip_code-container').html('');
      $('#office_business_contract_contact_zip_code').val('');
      $('#office_business_contract_contact_zip_code_id').val('');
    }

    $('#office_business_contract_contact_zip_code').attr('disabled', false);
  }
}

function set_establishments_list(data) {
  $('#establishments').empty();
  $('#establishments').append('<option>Sélectionner</option>');

  if (data) {
    data.forEach(function (entry) {

      let attributes = [];
      Object.getOwnPropertyNames(entry).forEach(function (attr){
        attributes.push(`data-${attr}="${entry[attr]}"`);
      })

      $('#establishments').append(
        `<option value=${entry.siret} ${attributes.join(' ')}>${entry.name} - ${entry.description} - ${entry.city}</option>`
      );
    });
  }
}

function set_contact_list(data) {
  $('select.establishment_contact_id').empty();
  $('select.establishment_contact_id').append('<option value="">Nouveau</option>');

  if (data) {
    data.establishment_contacts.forEach(function (entry) {

      let attributes = [];
      Object.getOwnPropertyNames(entry).forEach(function (attr){
        attributes.push(`data-${attr}="${entry[attr]}"`);
      })

      $('select.establishment_contact_id').append(
        `<option value=${entry.id} ${attributes.join(' ')}>${entry.first_name} ${entry.last_name}</option>`
      );
    });
  }
}

function toggle_billing_mode_fields() {
    $('#time-length-div').toggleClass('hide');
    $('#daily-order-amount-div').toggleClass('hide');
    $('#time-length-approx-div').toggleClass('hide');
}

function calculate_order_amount(){
    var ordered_days_val = $('#time-length-input').val();
    var daily_rate_val = $('#daily-order-amount-input').val();
    if(ordered_days_val && daily_rate_val){
        $('#billing-without-vat-input').val(ordered_days_val * daily_rate_val);
    }
}
