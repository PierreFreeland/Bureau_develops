function validateAmount(e) {
    var amountVal = $("#advance_amount").val() === '' ? 0 : parseFloat($("#advance_amount").val());
    var maxAmount = $("#amount_maximum").data("value") === '' ? 0 : parseFloat($("#amount_maximum").data("value"));
    var error = false;
    var form = e;

    if (amountVal <= 0) {
        error = "Veuillez renseigner un montant s’il vous plait";
    }
    else if (amountVal > maxAmount) {
        error = "Le montant doit être inférieur à l’avance maximum";
    }

    if (error) {
        $('.amount-advance-input .error-message').html(error);
        $('#advanceAmountModal .popup-message').html(error);
        $('#advanceAmountModal').modal();
        return false;
    } else {
        $('.amount-advance-input .error-message').html('');
        $('#advanceAmountModal .popup-message').html("Votre demande a bien été prise en compte. <br>Vous recevrez une réponse de votre correspondant très prochainement.");
        $('#advanceAmountModal').modal();
        $('#advanceAmountModal .btn').on('click', function() {
            $(form).trigger('submit');
        });
    }
}
