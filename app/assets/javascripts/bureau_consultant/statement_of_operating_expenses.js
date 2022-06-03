$(document).ready(function(){
  $('#save_line').on('click', function() {
    if (formSubmitted) {
      return false;
    }

    var amount_with_vat    = $('#office_operating_expense_line_total_with_taxes').val();
    var vat_rate           = $('#office_operating_expense_line_vat_id').find(':selected').data('vat-rate');
    var is_capital_asset   = $('#office_operating_expense_line_expense_type_id').find(':selected').data('capital-asset');
    var amount_without_vat = amount_with_vat / (1 + vat_rate/100);

    if (is_capital_asset && amount_without_vat >= 500) {
      $('#err_amount').modal('show');
      return false;
    }

    var $form = $(this).closest('form');
    var validators = $form[0].ClientSideValidations.settings.validators;
    if ($form.isValid(validators)) {
      formSubmitted = true;
    }
  });

  $("a#statement_of_operating_expenses_request_submit").on('click', function() {
      // retrieve comment
      var comment = $('textarea#statement_of_operating_expenses_request_comment').val()

      $('#loading').modal('show');

      // make an ajax query to validate
      $.ajax({
                url: '/bureau_consultant/statement_of_operating_expenses/current/submit',
                type: 'PUT',
                data: {
                  statement_of_operating_expenses_request: {
                    consultant_comment: comment
                  }
                }
            })
            .done(function(data) {
              $('#loading').modal('hide');
              $('#download').modal('show');
            })
            .fail(function(data) {
              $('#loading').modal('hide');
          });
    });

  $("a#download_pdf").on('click', function() {
      window.location.href = rootPathByVarient() + "/bureau_consultant/statement_of_operating_expenses_requests/history"
    });
  $("button#close_download_pdf").on('click', function() {
    window.location.href = rootPathByVarient() + "/bureau_consultant/statement_of_operating_expenses_requests/history"
  });

   $('.month-select-btn').hide();
   $('.month-select').change(function(){
     if($(this).val()) {
         $('.month-select-btn').show();
     }
   });

   $('.btn-comment').click(function(){
      $('.comment').show();
   });

   $('.btn-edit').click(function() {
       change_btn_title('MODIFIER', 'Modifier des dépenses de fonctionnement');
       $('#statement_of_operating_expenses tr').removeClass('selected');
       $(this).closest('tr').addClass('selected');
   });

   $('.btn-cancel').click(function(){
      change_btn_title('AJOUTER', 'Ajouter des dépenses de fonctionnement');
   });

   if ($('#vat_amount').length != 0) {
    updateVatAmount();

    $('#office_operating_expense_line_vat_id').change(function(){
        updateVatAmount();
     });

    $('input#office_operating_expense_line_total_with_taxes').on('keyup', function() {
        updateVatAmount();
      });
   }

   if ($('#office_operating_expense_line_expense_type_id').length != 0) {
      setExpenseVatFields();

      $('#office_operating_expense_line_expense_type_id').change(function(){
        setExpenseVatFields();
     });
   }
});

function change_btn_title(btn_text_value, title_text_value) {
    $('.btn-add-or-update').text(btn_text_value);
    $('.header-text-add-or-update').text(title_text_value)
}

function updateVatAmount() {
  var amount_with_vat    = $('#office_operating_expense_line_total_with_taxes').val();
  var vat_rate           = $('#office_operating_expense_line_vat_id').find(':selected').data('vat-rate');
  var amount_without_vat = amount_with_vat / (1 + vat_rate/100);
  var vat_amount         = amount_with_vat - amount_without_vat;

  $('span#vat_amount').text(vat_amount.toLocaleString('fr', {maximumFractionDigits: 2}));
}

function setExpenseVatFields() {
  var expense_type_has_vat = $('#office_operating_expense_line_expense_type_id').find(':selected').data('has-vat');

  if (expense_type_has_vat) {
    $('#vat-container').show();
  } else {
    $('#vat-container').hide();
  }
}
