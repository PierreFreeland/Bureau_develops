var delayTimer;

function submitSearchForm(e) {
  clearOtherSearchInput(e);
  clearTimeout(delayTimer);
  delayTimer = setTimeout(function() {
    var keyword = $(e).val();
    if ($.trim(keyword).length >= 3 || keyword.length == 0) {
      $(e).trigger("submit.rails");
      $(e).parent().addClass('loading')
    }
  }, 500);
}

function clearOtherSearchInput(e) {
  $('.search-form form input[type=search]').not(e).val('');
}