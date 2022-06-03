// The validator variable is a JSON Object
// The selector variable is a jQuery Object
window.ClientSideValidations.validators.local['decimal'] = function(element, options) {
  // Your validator code goes in here
  if (!/^(\d+(?:[\.\,]\d{1,2})?)$/.test(element.val())) {
    // When the value fails to pass validation you need to return the error message.
    // It can be derived from validator.message
    return options.message;
  }
}

window.ClientSideValidations.validators.local['optional_decimal'] = function(element, options) {
  // Your validator code goes in here
  if (!/^(\d+(?:[\.\,]\d{1,2})?){0,1}$/.test(element.val())) {
    // When the value fails to pass validation you need to return the error message.
    // It can be derived from validator.message
    return options.message;
  }
}
