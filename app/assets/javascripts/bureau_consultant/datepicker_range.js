$(function() {
  // Set startDate, endDate for datepicker with range in year.
  //
  // Example:
  //   <input class="datepicker" data-ending-date-target="#end_date" data-endind-date-year-period="3" type="text">
  //   <input class="datepicker" id="end_date" type="text">

  $('.datepicker[data-ending-date-target]').on('changeDate', function() {
    var targetPicker = $(this).data('ending-date-target');
    var periodYear = $(this).data('endind-date-year-period') || 3;

    var startDate = $('#start_date').data('datepicker').getDate();
    var maxDate = new Date(startDate);
    maxDate.setDate(maxDate.getDate() - 1);
    maxDate.setFullYear(maxDate.getFullYear() + periodYear);

    console.log(startDate);
    console.log(maxDate);

    // set_datepicker();

    $(targetPicker)
      .datepicker(
        {
          format: "dd/mm/yyyy",
          todayBtn: "linked",
          language: "fr",
          todayHighlight: true,
          allowInputToggle: true
        }
      )
      .datepicker('setStartDate', startDate)
      .datepicker('setEndDate', maxDate);
  });
});
