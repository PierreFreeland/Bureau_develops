$(function () {
    $(".monthpicker ").datepicker( {
        format: "mm/yyyy",
        viewMode: "months",
        minViewMode: "months"
    }).on('changeDate', function (ev) {
        $(this).datepicker('hide');
        window.edited = true;
        $(this).change().focusout();
    });
});