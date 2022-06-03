$(document).ready(function () {
  $('.help .panel-heading').click(function(){
    toggle_highlight($(this), 'hilight');
  });

  $('.search').click(function() {
     window.location.href = 'help/faq';
  });

  $('.faq .panel-heading').click(function() {
    toggle_highlight($(this), 'remove-border-bottom violet-border-top faq-hilight');
  });

  $('.search-categories').autocomplete({
     source: 'help/autocomplete_search_categories',
     minLength: 3
  });
});


function toggle_highlight(current_element, classes) {
    if(current_element.hasClass('normal')) {
        current_element.removeClass('normal');
        current_element.addClass(classes);
        current_element.find('.faq-title-text').addClass('faq-title-text-hilight');
    }
    else {
        current_element.addClass('normal');
        current_element.removeClass(classes);
        current_element.find('.faq-title-text').removeClass('faq-title-text-hilight');
    }
}
