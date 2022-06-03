$(document).ready(function () {
  // Usage: add class 'number-field' to input field you want to validate with numerical.
  function isNumberKey(e) {
    var allowedKeys = ['.', ',', 'Meta', 'Backspace', 'Delete', 'Tab', 'Shift', 'Enter', 'Alt', 'Control',
      'ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown'];

    if (!($.isNumeric(e.key) || $.inArray(e.key, allowedKeys) >= 0))
      return false;
    return true;
  }

  $('body').on('keypress', '.number-field', function(e) {
    return isNumberKey(e);
  });
});
