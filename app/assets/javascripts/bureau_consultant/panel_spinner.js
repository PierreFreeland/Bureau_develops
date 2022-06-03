$(document).ready(function () {
    $(".foldable-panel")
        .on('ajax:send', 'form[data-remote=true]', function () {
            $('.foldable-panel-spinner').show();
        });
});