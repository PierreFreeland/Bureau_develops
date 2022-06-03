$(document).ready(function() {

    // Script for displaying the service_type image when change the service_type combobox.
    displayServiceTypeIcon();
    $("#cms_page_service_type_id").on('change', displayServiceTypeIcon);

    function displayServiceTypeIcon() {
        var serviceTypeSelected = $("#cms_page_service_type_id option:selected");
        $("#service_type_image").attr('src', serviceTypeSelected.data('icon'));
    };

    // allow click on .foldable-right-panel.
    $('.foldable-right-panel').click(function(event){
        event.stopPropagation();
    });

  if ($('.page-show').length) {
    // replace fiches_services link from page content to point to bureau_consultant instead
    $('a').each(function () {
      var o = $(this);
      var patt = 'fiches_services/cms/pages';
      if (o.attr('href').match(patt) && !o.hasClass('btn-rouge')) {
        o.attr('href', o.attr('href').replace(patt, 'bureau_consultant/services'));
      }
    });

    // responsive
    $(".wicked-page-no").first().addClass('first');
    var div_img = $(".wicked-page-no.first > div:nth-child(2)")
    var img = div_img.find('img')
    div_img.css('background-image', 'url(' + img.attr('src') + ')');
    img.remove();
  }
});

// close right-panel popup when click outside popup.
$(window).click(function() {
    showLeftPanel();
});

// Script for hide/show left-right panel on 3 columns pages.
function showRightPanel() {
    toggleFoldableColumns($('.foldable-left-panel'), $('.foldable-right-panel'));
}
function showLeftPanel() {
    toggleFoldableColumns($('.foldable-right-panel'), $('.foldable-left-panel'));
}
function toggleFoldableColumns(elementToBeHide, elementToBeShow) {
    if(elementToBeHide.is(':visible')) {
        elementToBeHide.children().first().css('width', elementToBeHide.width());
        elementToBeHide.animate({width: 'toggle'}, 'fast');
    }

    if(elementToBeShow.is(':hidden')) {
        elementToBeShow.animate({width: 'toggle'}, 'fast', function() {
            elementToBeShow.children().first().css('width', 'auto');
            $("html, body").animate({ scrollTop: elementToBeShow.offset().top - 180 }, 'slow');
        });
    }
}