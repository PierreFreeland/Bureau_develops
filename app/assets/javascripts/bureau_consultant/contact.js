$(document).ready(function(){
  $('.icon-close').click(function(){
     hidden_element($('.mail-detail, .send-mail-success'));
  });

  $('.send-mail').click(function(){
     hidden_element($('.mail-detail'));
     show_element($('.send-mail-success'));

       $.ajax({
                 url: '/bureau_consultant/contacts',
                 type: 'POST',
                 data: {
                  contact: { message: $('#email-content').val() }
                }
             });
  });

  $('.show_send_mail').click(function(){
      if(window.innerWidth < 992) {
          $('html, body').animate({
              scrollTop: $("#scroll_to_this").offset().top
          }, 2000);
      }
  });
});
