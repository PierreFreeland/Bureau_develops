$(function () {

  $("#add_office_training_agreement_file_upload").on('click', function(event) {
      event.preventDefault();

      var contractFileUploadBlueprint = $("#office_training_agreement_file_upload_blueprint");
      var newUploadField = contractFileUploadBlueprint.clone(true);

    newUploadField.find("input[type=file]").attr("disabled", false);
    newUploadField.find("select").attr("disabled", false);
    newUploadField.removeAttr("id");
    newUploadField.show();

      $(".office_training_agreement_file_upload").last().after(newUploadField);
  });

  $(".remove_office_training_agreement_file_upload").on('click', function(event) {
      event.preventDefault();

      $(this).closest(".office_training_agreement_file_upload").remove();
  });

  if($(".office_training_agreement_file_upload:visible").length <= 0) {
      $("#add_office_training_agreement_file_upload").trigger('click');
  }

  $(".remove_office_training_agreement_uploaded_annex").on('click', function(event) {
      event.preventDefault();

      $('#Searching_Modal').modal('show');

      var annexID = $(this).closest(".office_training_agreement_uploaded_annex").attr('data-id');
      var contractID = $('#office_business_contract_id').val();
      var annexDom = $(this).closest(".office_training_agreement_uploaded_annex");

      $.ajax({
              url: '/bureau_consultant/office_training_agreements/' + contractID + '/annexes/' + annexID,
              type: 'DELETE'
          })
          .done(function(data) {
              $('#Searching_Modal').modal('hide');
              annexDom.remove();
          })
          .fail(function() {
            $('#Searching_Modal').modal('hide');
            alert( "erreur ne peut pas obtenir les données du serveur" );
        });
  });

  // hide remove file button by default
  $('.office_training_agreement_file_upload input').each(function() {
      if($(this).val() == "") {
          $(this).parent().find('.remove_office_training_agreement_file_upload').hide();
      }
  });

  // show remove file button when user browse the file.
  $('.office_training_agreement_file_upload input').on('change', function() {
      if($(this).val() != "") {
          $(this).parent().find('.remove_office_training_agreement_file_upload').show();
      }
  });

  update_total_expenses_amount();

  $('#office_business_contract_expenses').on('change', '.expense-cost input, .expense-number input, .expense-total input', update_expenses_amount);
  $('#office_business_contract_expenses_mobile').on('change', '.expense-cost input, .expense-number input, .expense-total input', update_expenses_amount);
  $('#office_business_contract_expenses').on('change', '.expense-cost input, .expense-number input, .expense-trainees input, .expense-total input', update_total_expenses_amount);
  $('#office_business_contract_expenses_mobile').on('change', '.expense-cost input, .expense-number input, .expense-trainees input, .expense-total input', update_total_expenses_amount);
});

function update_expenses_amount() {
  var fields = $(this).closest('.fields');
  var cost = fields.find('.expense-cost input').val();
  var number = fields.find('.expense-number input').val();
  var vat = $('select#office_business_contract_vat_id option:selected').data('vat-rate');

  // if(cost && number) {
  //   fields.find('.expense-total').text(update_total_expense_total(cost, number, vat).toLocaleString('fr') || '');
  // }
}

function update_total_expenses_amount() {
  var total_expense_cost = 0;
  var total_expense_number = 0;
  var total_expense_trainees = 0;
  var total_expense_total = 0;
  $('.expense-cost:visible input').each(function () { total_expense_cost += Number(this.value) || 0; });
  $('.expense-number:visible input').each(function () { total_expense_number += Number(this.value) || 0; });
  $('.expense-trainees:visible input').each(function () { total_expense_trainees += Number(this.value) || 0; });
  $('.expense-total:visible input').each(function () {total_expense_total += Number(this.value) || 0;})
  $('#office_business_contract_expenses_mobile .fields:visible').each(function () {
    var cost = $(this).find('.expense-cost input').val();
    var number = $(this).find('.expense-number input').val();
    var vat = $('select#office_business_contract_vat_id option:selected').data('vat-rate');

    total_expense_total += update_total_expense_total(cost, number, vat);
  })

  $('.total-expense-cost').text(total_expense_cost.toLocaleString('fr'));
  $('.total-expense-number').text(total_expense_number.toLocaleString('fr'));
  $('.total-expense-trainees').text(total_expense_trainees.toLocaleString('fr'));
  $('.total-expense-total').text(total_expense_total.toLocaleString('fr'));
}

function update_total_expense_total(cost, number, vat) {
  return cost * number * (100 + vat * 1) / 100;
}

// function set_value_trainig_agreement(data) {
//    if(data) {
//        $('#office_business_contract_establishment_id').val(data.id);
//        $('#office_business_contract_establishment_name').val(data.name).change().focusout();
//        $('#office_business_contract_vat_number').val(data.vat_number).change().focusout();
//        $('#office_business_contract_siret').val(data.siret).change().focusout();
//        $('#office_business_contract_address_2').val(data.address_line1).change().focusout();
//        $('#office_business_contract_city').val(data.zipcode_city).change().focusout();
//        $('#office_business_contract_country_id').val(data.country_id).change().focusout();
//        $('#office_business_contract_phone').val(data.tel_number).change().focusout();
//        $('#office_business_contract_email').val(data.email).change().focusout();
//        $('#office_business_contract_address_1').val(data.contact_name).change().focusout();
//    }
//    else {
//        $('#office_business_contract_vat_number, #office_business_contract_establishment_name,' +
//          '#office_business_contract_siret, #office_business_contract_address_2,' +
//          '#office_business_contract_city, #office_business_contract_country_id,' +
//          '#office_business_contract_phone, #office_business_contract_email,' +
//          '#office_business_contract_address_1').val('');
//    }
// }

