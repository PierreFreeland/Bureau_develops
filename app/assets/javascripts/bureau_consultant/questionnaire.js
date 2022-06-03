$(document).ready(function() {
  var visibility_buffer = $('.js-questionnaire-visibility :checkbox');

  $('[data-next]').click(function () {
    var element = $(this);
    var container = element.closest('.js-questionnaire-container');
    var element_btns = container.find('.js-questionnaire-element>.btn');
    var containers = container.parent().children('.js-questionnaire-container');
    var next_container = element.attr('data-next').substr(1, 1) == 'q' ? container.next() : containers.last();
    var next_elements = next_container.find('.js-questionnaire-element');
    var next_element_btns = next_container.find('.js-questionnaire-element>.btn');
    var display_elements = $(element.attr('data-next'));
    var scroll_top_space = $('#scroll_top_space');
    var $window = $(window);
    var col_right = $('.col-right .bg-white');
    var body = $('html,body');

    element_btns.removeClass('hover');
    element.addClass('hover');

    for (var i = container.index() + 1; i < containers.length; i++) {
      containers.eq(i).hide();
    }
    next_container.show();

    next_elements.hide();
    next_element_btns.removeClass('hover');
    display_elements.show();
    scroll_top_space.css('min-height', $window.height() - ((col_right.offset().top + col_right.height()) - next_container.offset().top) - 246);
    body.stop().animate({ scrollTop: next_container.offset().top - 150 }, 500);

    visibility_buffer.each(function () {
      var o = $(this);
      o.prop('checked', $(o.val() + '>.btn').hasClass('hover'));
    });
  });

  visibility_buffer.filter(':checked').each(function () {
    $('.btn', $(this).val()).click();
  });
});
