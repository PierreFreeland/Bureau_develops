$(function() {

  /* Scroll back at top when closing modal */
  $("body.mobile-app .modal").on('hidden.bs.modal', function (e) {
    $('div.mobile-right-content').scrollTop(0);
  });

});
