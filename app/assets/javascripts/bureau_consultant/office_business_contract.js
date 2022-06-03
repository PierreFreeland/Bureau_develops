$(function () {
  var expense_row = $('#office_business_contract_expenses').find('tr.fields:visible').length;

  $('#office_business_contract_expenses').on('nested:fieldAdded', function () {
    expense_row = $(this).find('tr.fields:visible').length;
    expense_plus_icon_control(expense_row)
  });

  $('#office_business_contract_expenses').on('nested:fieldRemoved', function () {
    expense_row = $(this).find('tr.fields:visible').length;
    expense_plus_icon_control(expense_row)
    update_total_expenses_amount()
  });


  expense_plus_icon_control(expense_row)
})

function expense_plus_icon_control(expense_row) {
  if(expense_row == 5) {
    $('.business-contract-expenses-plus').hide();
  }else {
    $('.business-contract-expenses-plus').show();
  }
}
