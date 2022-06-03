var serializeHash = function () {
    var attrs = {};

    $.each($(this).serializeArray(), function(i, field) {
        attrs[field.name] = field.value;
    });

    return attrs;
};

$.fn.extend({ serializeHash: serializeHash });