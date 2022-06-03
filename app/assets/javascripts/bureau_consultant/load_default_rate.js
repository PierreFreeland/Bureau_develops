function loadDefaultCountryVatRate(countryCode, updateElement) {
    $('#loading').modal('show');
    $.ajax({
        url: "/bureau_consultant/commercial_contracts/load_default_vat_rate",
        data: {country_code: countryCode}
    }).done(function(data) {
        if (data === null) {
          $(updateElement).val(1);
        } else {
          $(updateElement).val(data);
        }
    });
    $('#loading').modal('hide');
};
