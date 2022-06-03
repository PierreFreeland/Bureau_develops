var formOriginalData = [];
var formSubmitted = false;

$(document).ready(function () {
    $('.add-postal-code-tab').hide();

    if (window.location.hash == '#manage_zipcode') {
        $('.set-calendar-tab').hide();
        $('.add-postal-code-tab').show();
    }

    $('.add-postal-code').click(function () {
        $('.set-calendar-tab').hide();
        $('.add-postal-code-tab').show();
    });

    $('.remove-postal-code').click(function () {
        $('.set-calendar-tab').show();
        $('.add-postal-code-tab').hide();
    });

    $('.load_first_possible_month').on('click', function () {
        $('#statement_of_activities_request_date').html(first_possible_month_option)
    });

    $('#create_empty').on('click', function () {
        $('#statement_of_activities_request_no_activity').val('true')
        $('#declaration_form').submit();
    });

    $('#no_activity_with_salary').on('click', function () {
        var selected_date = $('#statement_of_activities_request_date').val()

        window.location.href = rootPathByVarient() + "/bureau_consultant/statement_of_activities/synthesis_2_step?statement_of_activities_request[date]=" + selected_date
    });

    $('#create_previous_empty').on('click', function () {
        $('#loading').modal('show');

        $.ajax({
            url: '/bureau_consultant/statement_of_activities/create_previous_empty',
            type: 'POST'
        })
            .done(function (data) {
                $('#loading').modal('hide');
                $('#confirm').modal('hide');
            })
            .fail(function (data) {
                // TODO : handle failure
            });
    });

    $('#duplicate_for_whole_month, #duplicate_for_few_days').on('click', function () {
        $('#loading').modal('show');

        if ($('form.new_office_activity_report_line').length > 0) {
            $('form.new_office_activity_report_line').attr('action', $(this).data('url'));
            $('form.new_office_activity_report_line').submit();
        }

        if ($('form.edit_office_activity_report_line').length > 0) {
            $('form.edit_office_activity_report_line').attr('action', $(this).data('url'));
            $('form.edit_office_activity_report_line').submit();
        }
    });

    //for store multi date select at duplicate_new page
    var duplicate_multi_selected_date = {};
    duplicate_multi_selected_date['data'] = [];

    if ($('#calendar-view').length > 0) {
        $('#calendar-view').fullCalendar({
            locale: 'fr',
            defaultDate: current_month,
            dayClick: function (date, jsEvent, view) {
                if ($('.fc-day-top[data-date=' + date.format() + ']').attr('disabled') == "disabled") {
                    return false;
                } else {
                    window.location.href = rootPathByVarient() + "/bureau_consultant/statement_of_activities/manage_activity_day?date=" + date.format();
                }
            }
        });

        disable_all_calendar();
        loop_set_enable_date(selectable_days);
    }

    $(".office_activity_report .btn[data-value='" + $('#office_activity_report_mission_in_foreign_country').val() + "']").addClass('selected');

    $(".office_activity_report .btn").on('click', function () {
        $(".office_activity_report .btn").removeClass('selected');
        $(this).addClass('selected');
        $('#office_activity_report_mission_in_foreign_country').val($(this).data('value'));
    });

    $("#office_activity_report_line_activity_type_id").on('change', function () {
        var option = $(this).find(':selected');
        if (option.attr('data-absence')) {
            $(".activity-time-span .btn:not(:last-child)").addClass('disabled', option.attr('data-absence'));
            var full_time_span = $(".activity-time-span .btn:last-child");
            $(".activity-time-span .btn").removeClass('selected');
            full_time_span.addClass('selected');
            $('#office_activity_report_line_time_span').val(full_time_span.data('value'));
        } else {
            $(".activity-time-span .btn:not(:last-child)").removeClass('disabled', option.attr('data-absence'));
        }
    }).change();

    $(".activity-time-span .btn[data-value='" + $('#office_activity_report_line_time_span').val() + "']").addClass('selected');

    $(".activity-time-span .btn").on('click', function () {
        if (!$(this).hasClass('disabled')) {
            $(".activity-time-span .btn").removeClass('selected');
            $(this).addClass('selected');
            $('#office_activity_report_line_time_span').val($(this).data('value'));
        }
    });

    if ($('span#max_expenses_reimbursement').length != 0) {
        setMaxExpensesReimbursement();
        $('input#office_activity_report_gross_wage').on('keyup', function () {
            setMaxExpensesReimbursement();
        });
    }

    if ($('span#gross_complementary').length != 0) {
        setGrossComplementary();
        $('input#office_activity_report_gross_wage').on('keyup', function () {
            setGrossComplementary();
        });
    }

    $("a#statement_of_activities_validate_empty").on('click', function () {

        // retrieve comment & requested salary
        var date = $('input#date').val()
        var requested_salary = $('input#office_activity_report_gross_wage').val()

        $('#loading').modal('show');

        // make an ajax query to validate
        $.ajax({
            url: '/bureau_consultant/statement_of_activities/submit',
            type: 'PUT',
            data: {
                statement_of_activities_request: {
                    date: date,
                    no_activity: true,
                    gross_wage: requested_salary
                }
            }
        })
            .done(function (data) {
                $('#loading').modal('hide');
                $('#confirmation').modal('show');
            })
            .fail(function (data) {
                $('#loading').modal('hide');
                $('#max_salary_error').modal('show');
                $('input#office_activity_report_gross_wage').val(gross_salary);
                $('span#gross_complementary').html('0');
            });
    });

    $("a#statement_of_activities_validate_from_expenses").on('click', function () {
        $('#loading').modal('show');

        // make an ajax query to validate
        $.ajax({
            url: '/bureau_consultant/statement_of_activities/submit',
            type: 'PUT',
            data: {
                office_activity_report: {
                    foo: 'bar'
                }
            }
        })
            .done(function (data) {
                $('#loading').modal('hide');
                $('#validate').modal('hide');
                $('#download').modal('show');
            })
            .fail(function (data) {
                // deal with it
            });
    });

    $("a#statement_of_activities_submit").on('click', function (e) {
        e.preventDefault();
        var href = $(this).attr('href');
        // retrieve comment & requested salary
        var activities_only = $(this).data('activities-only');

        var form = $('form.edit_office_activity_report')[0];
        var data = new FormData(form);

        if (activities_only != undefined) {
            data.append('activities_only', activities_only);
        }

        $('#loading').modal('show');

        // make an ajax query to validate
        $.ajax({
            url: '/bureau_consultant/statement_of_activities/submit',
            type: 'PUT',
            enctype: 'multipart/form-data',
            data: data,
            processData: false,
            contentType: false,
            cache: false,
            timeout: 600000

        })
            .done(function (data) {
                if (href[0] !== '#') {
                    window.location.href = href;
                } else {
                    $('#error_explanation').hide();
                    $('#loading').modal('hide');
                    $('#validate').modal('hide');
                    if (activities_only && granted_expenses) {
                        $('#confirmation').modal('show');
                    } else {
                        $('#download').modal('show');
                    }
                }
            })
            .fail(function (data) {
                $('#loading').modal('hide');
                $('#validate').modal('hide');
                $('input#office_activity_report_gross_wage').val(gross_salary);
                $('span#gross_complementary').html('0');

                var errors = ""

                for (var i = 0; i < data.responseJSON['errors'].length; i++) {
                    errors += "<li>" + data.responseJSON['errors'][i] + "</li>"
                }

                $('#error_explanation').html("<ul>" + errors + "</ul>");

                $('#error_explanation').show();
            });
    });

    $("a#statement_of_activities_validate").on('click', function () {
        // retrieve comment & requested salary
        var activities_only = $(this).data('activities-only')

        var form = $('form.edit_office_activity_report')[0];
        var data = new FormData(form);

        if (activities_only != undefined) {
            data.append('activities_only', activities_only);
        }

        $('#loading').modal('show');

        // make an ajax query to validate
        $.ajax({
            url: '/bureau_consultant/statement_of_activities/validate',
            type: 'PUT',
            enctype: 'multipart/form-data',
            data: data,
            processData: false,
            contentType: false,
            cache: false,
            timeout: 600000

        })
            .done(function (data) {
                $('#error_explanation').hide();
                $('#loading').modal('hide');
                $('#validate').modal('show');
            })
            .fail(function (data) {
                $('#loading').modal('hide');
                $('input#office_activity_report_gross_wage').val(gross_salary);
                $('span#gross_complementary').html('0');

                var errors = ""

                for (var i = 0; i < data.responseJSON['errors'].length; i++) {
                    errors += "<li>" + data.responseJSON['errors'][i] + "</li>"
                }

                $('#error_explanation').html("<ul>" + errors + "</ul>");

                $('#error_explanation').show();
            });
    });

    $("a#statement_of_activities_download_pdf").on('click', function () {
        if (window.location.href.match('/m/') != null) {
            setInterval(function(){
              window.location.href = rootPathByVarient() + "/bureau_consultant/home";
            }, 1000);
        } else {
            window.location.href = rootPathByVarient() + "/bureau_consultant/statement_of_activities_requests/history"
        }
    });

    $("button#close_statement_of_activities_download_pdf").on('click', function () {
       if (window.location.href.match('/m/') != null) {
            window.location.href = rootPathByVarient() + "/bureau_consultant/home"
        } else {
            window.location.href = rootPathByVarient() + "/bureau_consultant/statement_of_activities_requests/history"
        }
    });

    // for mock up
    if ($("#calendar-view.mock").length > 0) {
        for (var i = 0; i < selectable_days.length; i++) {
            var day_calendar = '.fc-day-top[data-date="' + selectable_days[i] + '"]';
            var values = { mission: 0, development: 0, unemployment: 0, absence: 0 };
            $(day_calendar).removeClass('add-disable-calendar');

            if (days_with_activity[selectable_days[i]]) {
                $(day_calendar).popover({
                    content: days_with_activity[selectable_days[i]]['label'].join(' / '),
                    trigger: 'hover',
                    container: 'body',
                    placement: 'auto right'
                });
                values.mission = days_with_activity[selectable_days[i]]['mission'] * 100;
                values.development = days_with_activity[selectable_days[i]]['development'] * 100;
                values.unemployment = days_with_activity[selectable_days[i]]['unemployment'] * 100;
                values.absence = days_with_activity[selectable_days[i]]['absence'] * 100;
            }

            $(day_calendar).append(div_progess_bar());
            add_style_progess_bar(day_calendar, values);
        }
        for (var i = 0; i < out_of_contract_days.length; i++) {
            var day_calendar = '.fc-day-top[data-date="' + out_of_contract_days[i] + '"]';
            $(day_calendar).popover({
                content: 'Pas de contrat de travail',
                trigger: 'hover',
                container: 'body',
                placement: 'auto right'
            });
        }

    } else if ($(".duplicate-calendar-view").length > 0) {
        $('.duplicate-calendar-view').fullCalendar({
            locale: 'fr',
            defaultDate: current_month,
            dayClick: function (date, jsEvent, view) {
                if ($('.fc-day-top[data-date=' + date.format() + ']').attr('disabled') == "disabled") {
                    return false;
                } else {
                    $('#loading').modal('show');
                    selectMultidate('.duplicate-calendar-view', date.format(), duplicate_multi_selected_date['data']);
                    updateSelectedDateCount(duplicate_multi_selected_date['data']);
                    $('#loading').modal('hide');
                }
            }
        });

        disable_all_calendar();
        loop_set_enable_date(selectable_days);

        for (var i = 0; i < selectable_days.length; i++) {
            var day_calendar = '.fc-day-top[data-date="' + selectable_days[i] + '"]';
            var values = { mission: 0, development: 0, unemployment: 0, absence: 0 };

            if (days_with_activity[selectable_days[i]]) {
                $(day_calendar).popover({
                    content: days_with_activity[selectable_days[i]]['label'].join(' / '),
                    trigger: 'hover',
                    container: 'body',
                    placement: 'auto right'
                });
                values.mission = days_with_activity[selectable_days[i]]['mission'] * 100;
                values.development = days_with_activity[selectable_days[i]]['development'] * 100;
                values.unemployment = days_with_activity[selectable_days[i]]['unemployment'] * 100;
                values.absence = days_with_activity[selectable_days[i]]['absence'] * 100;
            }

            $(day_calendar).append(div_progess_bar());
            add_style_progess_bar(day_calendar, values);
        }
        for (var i = 0; i < out_of_contract_days.length; i++) {
            var day_calendar = '.fc-day-top[data-date="' + out_of_contract_days[i] + '"]';
            $(day_calendar).popover({
                content: 'Pas de contrat de travail',
                trigger: 'hover',
                container: 'body',
                placement: 'auto right'
            });
        }
    } else if ($(".insert-calendar-view").length > 0) {
        var date = new Date();
        month = ("0" + (date.getMonth() + 1)).slice(-2);
        day = 10;
        var add_progess_bar_at_date = '2018-' + month + '-' + day;

        var progess_bar_selector = '.fc-day-top[data-date="' + add_progess_bar_at_date + '"]';
        var variant_sizes = [0, 15, 30, 50, 70, 90, 100];
        left_bar_size = variant_sizes[Math.floor(Math.random() * variant_sizes.length)];
        right_bar_size = 100 - left_bar_size;
        var values = { mission: left_bar_size, development: right_bar_size, unemployment: 0, absence: 0 };

        $(progess_bar_selector).append(div_progess_bar());
        add_style_progess_bar(progess_bar_selector, values);
    }

    $('.add-postal-code').click(function () {
        $('.set-calendar-tab').hide();
        $('.add-postal-code-tab').show();
    });

    $('.remove-postal-code').click(function () {
        $('.set-calendar-tab').show();
        $('.add-postal-code-tab').hide();
    });

    $('.finish').click(function () {
        json_obj = JSON.stringify(duplicate_multi_selected_date);
        $('#duplicated_line_selected_dates').val(json_obj);
    });

    function updateSelectedDateCount(selectedDates) {
        $('#selected-date-count').html(selectedDates.length);
    }

    $('.open-and-close').click(function () {
        $('#download').modal('hide');
    });


    if($('.add-line-statement-of-activities-wrap').length > 0) {
        $('body').addClass('add-activty-page');

        var days_with_activity_array = $.map(days_with_activity, function (value, index) {
            return [setFormatDateforDatepicker(index)];
        });

        $('.datepicker-special').datepicker({
            datesDisabled: days_with_activity_array,
            language: 'fr',
            defaultViewDate: {
                month: month
            },
            minViewMode: 0,
            maxViewMode: 0,
            startDate: setFormatDateforDatepicker(current_month),
            endDate: setFormatDateforDatepicker(end_of_month),
            autoclose: true
        });
    }

    $('#activity-forms-btn').click(function () {
        var data = [];
        $('#activity-forms-div form').each(function() {
            var id = $(this).attr('id');

            var originalData = formOriginalData.find(function(x) {
                return x.form_id === id;
            });

            if (originalData !== undefined)
            {
                var changeData = filterSerializeData($(this).serializeHash());

                if(JSON.stringify(changeData) !== JSON.stringify(originalData.value)) {
                    data.push({form_id: $(this).attr('id'), value: changeData});
                }
            }
        });
        // make an ajax query to validate
        $.ajax({
            url: '/bureau_consultant/statement_of_activities/update_batch_expense',
            type: 'POST',
            dataType: 'script',
            data: {
                data: data
            }
        });
        return false
    });

    if ($('.select-expense-type').length != 0) {
        setActivitiesExpenseVatFields();

        $('.select-expense-type').change(function () {
            current_element = $(this);
            setActivitiesExpenseVatFieldsSelected(current_element);
            current_element.closest('form').resetClientSideValidations();
        });
    }

    if ($('.select-expense-type').length != 0) {
        setLineInputFields();

        $('.select-expense-type').change(function () {
            var current_element = $(this)
            current_element.closest('form').resetClientSideValidations();
            setLineInputFieldsSelected(current_element);
        });
    }
});

function setFormatDateforDatepicker(date) {
    var new_date = date.split('-');
    var new_date_align = new_date[2]+'-'+new_date[1]+'-'+new_date[0];

    return new_date_align
}

function setLineInputFields() {
    var expense_type_is_distance = $('.select-expense-type').find(':selected').data('is-distance');

    if (expense_type_is_distance) {
            $('.statement_of_activities_line_distance_field input[type=text]').prop('disabled', false);
            $('.expense-label').attr('placeholder', 'Trajet effectué');
            $('.statement_of_activities_line_amount_field input[type=text]').prop('disabled', true);
    } else {
            $('.statement_of_activities_line_distance_field input[type=text]').prop('disabled', true);
            $('.statement_of_activities_line_amount_field input[type=text]').prop('disabled', false);
            $('.expense-label').attr('placeholder', 'Libellé');
    }
}

function setLineInputFieldsSelected(current_element) {
    var expense_type_is_distance = current_element.find(':selected').data('is-distance')

    if (expense_type_is_distance) {
        current_element.closest('form').find('.statement_of_activities_line_distance_field input[type=text]').prop('disabled', false);
        current_element.closest('form').find('.expense-label').attr('placeholder', 'Trajet effectué');
        current_element.closest('form').find('.statement_of_activities_line_amount_field input[type=text]').prop('disabled', true);
        current_element.closest('form').find('.statement_of_activities_line_amount_field input[type=text]').val('');
    } else {
        current_element.closest('form').find('.statement_of_activities_line_distance_field input[type=text]').prop('disabled', true);
        current_element.closest('form').find('.statement_of_activities_line_distance_field input[type=text]').val('');
        current_element.closest('form').find('.statement_of_activities_line_amount_field input[type=text]').prop('disabled', false);
        current_element.closest('form').find('.expense-label').attr('placeholder', 'Libellé');
    }
}

function setGrossComplementary() {
    var requested = $('input#office_activity_report_gross_wage').val().replace(',', '.')
    var complementary = requested - gross_salary

    if (complementary < 0)
        complementary = 0

    $('span#gross_complementary').text(complementary.toLocaleString('fr', {maximumFractionDigits: 2}));
}

function setMaxExpensesReimbursement() {
    var gross_wage = $('input#office_activity_report_gross_wage').val()
    var max_expenses_reimbursement = max_expenses - gross_wage * salr_brut

    if (max_expenses_reimbursement < 0)
        max_expenses_reimbursement = 0

    $('span#max_expenses_reimbursement').text(max_expenses_reimbursement.toLocaleString('fr', {maximumFractionDigits: 2}));
}

function declarationChoicesSelect(btnElement, choicesTarget) {
    $(".declaration_choices").hide();
    $("#declaration_choices_selection .btn").removeClass('selected');

    $(btnElement).addClass('selected');
    $(choicesTarget).removeClass('hidden');
    $(choicesTarget).show();
}

function addCircleActive(container, date) {
    $(container + ' .fc-day-top span.fc-day-number').removeClass('actived');
    $(container + ' .fc-day-top[data-date="' + date + '"] span.fc-day-number').addClass('actived');
}

function selectMultidate(container, date, date_array) {
    if ($(container + ' .fc-day-top[data-date="' + date + '"]').hasClass('selected-date')) {
        date_array.pop(date);
        $(container + ' .fc-day-top[data-date="' + date + '"]').removeClass('selected-date');
    } else {
        date_array.push(date);
        $(container + ' .fc-day-top[data-date="' + date + '"]').addClass('selected-date');
    }
}

function div_progess_bar() {
    return '<div class="calendar-progess-bar activity-type-mission"></div>' +
        '<div class="calendar-progess-bar activity-type-development"></div>' +
        '<div class="calendar-progess-bar activity-type-unemployment"></div>' +
        '<div class="calendar-progess-bar activity-type-absence"></div>'
}

function add_style_progess_bar(selector, values) {
    var left = 0;
    $(selector + ' .activity-type-mission').css({width: values.mission + '%', left: left + '%'});
    left += values.mission;
    $(selector + ' .activity-type-development').css({width: values.development + '%', left: left + '%'});
    left += values.development;
    $(selector + ' .activity-type-unemployment').css({width: values.unemployment + '%', left: left + '%'});
    left += values.unemployment;
    $(selector + ' .activity-type-absence').css({width: values.absence + '%', left: left + '%'});
}

function disable_all_calendar() {
    $('.fc-day-top').addClass('disable-calendar');
    $('.fc-day-top').attr('disabled', 'disabled');
}

function enable_date_calendar(date) {
    $('.fc-day-top[data-date=' + date + ']').removeClass('disable-calendar');
    $('.fc-day-top[data-date=' + date + ']').removeAttr('disabled', false);
}

function loop_set_enable_date(date_lists) {
    for (var i = 0; i < date_lists.length; i++) {
        enable_date_calendar(date_lists[i]);
    }
}

function add_highlight_manage_activities_day(date) {
    $('.fc-day-top').removeClass('selected-date');
    $('.fc-day-top[data-date=' + date + ']').addClass('selected-date');
}

function setActivitiesExpenseVatFields() {
    var expense_type_has_vat = $('.select-expense-type').find(':selected').data('has-vat');

    if (expense_type_has_vat) {
        $('.vat-container input[type=text]').prop('disabled', false);
    }
    else {
        $('.vat-container input[type=text]').prop('disabled', true);
    }
}

function setActivitiesExpenseVatFieldsSelected(current_element) {
    var expense_type_has_vat = current_element.find(':selected').data('has-vat');

    if (expense_type_has_vat) {
        current_element.closest('form').find('.vat-container input[type=text]').prop('disabled', false);
    }
    else {
        current_element.closest('form').find('.vat-container input[type=text]').prop('disabled', true);
        current_element.closest('form').find('.vat-container input[type=text]').val('');
    }
}

function initOrginalFormData() {
    $('#activity-forms-div form').each(function() {
        $(this)[0].reset();
        var data = filterSerializeData($(this).serializeHash());
        formOriginalData.push({form_id: $(this).attr('id'), value: data });
    });
}

function filterSerializeData(data) {
    delete data['authenticity_token'];
    delete data['utf8'];
    return data
}
