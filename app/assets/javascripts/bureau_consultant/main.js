$(document).ready(function() {

    // Bootstrap tooltip and popover
    $("[data-toggle=popover]").popover();
    $("[data-toggle=tooltip]").tooltip();

    // Disable links and buttons inside .disabled-links-container element
    $('.disabled-links-container a, .disabled-links-container .btn').addClass('disabled');
    $('.disabled-links-container a').attr('href', '#').click(function(e) { e.preventDefault() });
});