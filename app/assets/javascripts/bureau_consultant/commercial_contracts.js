$(document).ready(function() {
    $("#add_commercial_contract_file_upload").on('click', function(event) {
        event.preventDefault();

        var contractFileUploadBlueprint = $("#commercial_contract_file_upload_blueprint");
        var newUploadField = contractFileUploadBlueprint.clone(true);

        newUploadField.find("input[type=file]").attr('disabled', false);
        newUploadField.removeAttr('id');
        newUploadField.show();

        $(".commercial_contract_file_upload").last().after(newUploadField);
    });

    $(".remove_commercial_contract_file_upload").on('click', function(event) {
        event.preventDefault();

        $(this).closest(".commercial_contract_file_upload").remove();
    });

    if($(".commercial_contract_file_upload:visible").length <= 0) {
        $("#add_commercial_contract_file_upload").trigger('click');
    }

    $(".remove_commercial_contract_uploaded_annex").on('click', function(event) {
        event.preventDefault();

        $('#Searching_Modal').modal('show');

        var annexID = $(this).closest(".commercial_contract_uploaded_annex").attr('data-id');
        var contractID = $('#office_business_contract_id').val();
        var annexDom = $(this).closest(".commercial_contract_uploaded_annex");

        $.ajax({
                url: '/bureau_consultant/commercial_contracts/' + contractID + '/annexes/' + annexID,
                type: 'DELETE'
            })
            .done(function(data) {
                $('#Searching_Modal').modal('hide');
                annexDom.remove();
            })
            .fail(function() {
              $('#Searching_Modal').modal('hide');
              alert( "erreur ne peut pas obtenir les données du serveur" );
          });
    });

    // hide remove file button by default
    $('.commercial_contract_file_upload input').each(function() {
        if($(this).val() == "") {
            $(this).parent().find('.remove_commercial_contract_file_upload').hide();
        }
    });

    // show remove file button when user browse the file.
    $('.commercial_contract_file_upload input').on('change', function() {
        if($(this).val() != "") {
            $(this).parent().find('.remove_commercial_contract_file_upload').show();
        }
    });

    // js for loading the default vat rate from selected country.
    if($('#office_business_contract_establishment_country_id').length) {
        set_zip_code_requirement_for_contract();
        loadDefaultCountryVatRate($("#office_business_contract_establishment_country_id").val(), $('#office_business_contract_vat_id'));
    }

    $("#office_business_contract_establishment_country_id").change(function(){
        set_zip_code_requirement_for_contract();
        loadDefaultCountryVatRate($(this).val(), $('#office_business_contract_vat_id'));
    });

    if($('#office_business_contract_contact_country_id').length) {
        set_zip_code_requirement_for_contract();
    }

    $("#office_business_contract_contact_country_id").change(function(){
        set_zip_code_requirement_for_contract();
    });
});

function set_zip_code_requirement_for_contract() {
    return;
    if ($("#office_business_contract_establishment_country_id").val() == 1) {
        $('label[for="office_business_contract_establishment_zip_code"]').addClass('required');
        $('input#office_business_contract_establishment_zip_code').enableClientSideValidations();
    } else {
        $('label[for="office_business_contract_establishment_zip_code"]').removeClass('required');
        $('input#office_business_contract_establishment_zip_code').disableClientSideValidations();
    }

    if ($("#office_business_contract_contact_country_id").val() == 1) {
        $('label[for="office_business_contract_contact_zip_code"]').addClass('required');
        $('input#office_business_contract_contact_zip_code').enableClientSideValidations();
    } else {
        $('label[for="office_business_contract_contact_zip_code"]').removeClass('required');
        $('input#office_business_contract_contact_zip_code').disableClientSideValidations();
    }
}

$(function () {
    window.edited = false;

    var edited_on = function () {
        window.edited = true;
    };

    // form input
    $('input, textarea, select').not('.datepicker').on('change', edited_on);

    $('button.reset-form').click(function(e){
          if(window.confirm('Voulez-vous continuer votre dernier contrat en cours de saisie ? ') == true) {
              window.location.replace(rootPathByVarient() + '/bureau_consultant/commercial_contracts/contract_request/pending/destroy');
          }else {
              return true;
          }
    });
});
