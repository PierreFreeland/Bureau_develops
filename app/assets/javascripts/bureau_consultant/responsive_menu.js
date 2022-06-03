$(document).ready(function () {
  /* Javascript for control the responsive side menu. */
  var menuShow = false;

  $('#menu-btn, #mask').click(toggleResponsiveMenu);

  $('.hasSubMenu').click(function () {
    $(this).parents('li').find('ul').toggle();
    return false;
  });

  $('a.stat.disabled').popover('disable').click(function(e) { e.preventDefault() });

  function toggleResponsiveMenu() {
    $('#menu').animate({
      right: menuShow ? "-=250" : "+=250"
    }, 200, function () {
      menuShow = !menuShow;
      $('#mask').toggle();
    });
  }
});