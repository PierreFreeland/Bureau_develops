$(function () {
  set_default_zipcode_field();
  register_country_select2();
  call_zipcode_selecte2();
});

function set_default_zipcode_field() {
  var country_fields = $("[class*='selected-country']").length

  for (i = 1; i <= country_fields; i++) {
    var country_id = $(".selected-country" + i).val();
    zipcode_fields_switch(country_id, i)
  }

}

function register_country_select2() {
  $("[class*='selected-country']").change(function () {
    var country_id = $(this).val();
    var get_class = $(this).attr('class').split(' ').find(a => a.includes("selected-country"))
    var class_number = get_class.substr(get_class.length - 1)
    zipcode_fields_switch(country_id, class_number)
  })
}

function call_zipcode_selecte2() {
  $(".zip-code-select2").select2({
    minimumInputLength: 3,
    ajax: {
      url: "/bureau_consultant/load_zipcode",
      type: "get",
      dataType: 'json',
      delay: 250,
      data: function (params) {
        return {
          zip_code: params.term // search term
        };
      },
      processResults: function (response) {
        return {
          results: $.map(response, function (obj) {
            return obj;
          })
        };
      },
    }
  });

  $(".zip-code-select2[class*='zipcode']").change(function () {
    if ($(this).attr('disabled') != 'disabled') {
      if ($(this).select2('data')[0]) {
        var city_name = $(this).select2('data')[0].city_name || $(this).data('cityName')
        var get_class = $(this).attr('class').split(' ').find(a => a.includes("zipcode"))
        var class_number = get_class.substr(get_class.length - 1)
        $('.city-from-zipcode' + class_number).val(city_name).change();
        $('.zipcode_id' + class_number).val($(this).find('option:selected').data().data.zip_code_id || $(this).data('zipcodeId'))
      }
    }
  })
}

function zipcode_fields_switch(country_id, class_number) {
  if (country_id === '1') {
    $(".other-country" + class_number).hide();
    $(".other-country" + class_number + " input").attr('disabled', true);

    $(".in-france" + class_number).show();
    $(".in-france" + class_number + " select").attr('disabled', false);
    $('.city-from-zipcode' + class_number).prop('readonly', true);
  } else {

    $(".in-france" + class_number).hide();
    $(".in-france" + class_number + " select").attr('disabled', true);

    $(".other-country" + class_number).show();
    $(".other-country" + class_number + " input").val('');
    $(".other-country" + class_number + " input").attr('disabled', false);
    $('.city-from-zipcode' + class_number).prop('readonly', false);
  }

  if ($('.zipcode' + class_number).data('selected-id')) {
    var append_option = new Option($('.zipcode' + class_number).data('selected-text'), $('.zipcode' + class_number).data('selected-id'), true, true);
    $(".zipcode" + class_number).append(append_option).change();
  }
}
