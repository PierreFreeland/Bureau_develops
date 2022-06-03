class DecimalValidator < ActiveModel::EachValidator
  def validate_each(record, attr_name, value)
  	# empty validation on the model side, just here to allow JS validation to be triggered
  end
end

class OptionalDecimalValidator < ActiveModel::EachValidator
  def validate_each(record, attr_name, value)
    # empty validation on the model side, just here to allow JS validation to be triggered
  end
end

# This allows us to assign the validator in the model
module ActiveModel::Validations::HelperMethods
  def validates_decimal(*attr_names)
    validates_with DecimalValidator, _merge_attributes(attr_names)
  end

  def validates_optional_decimal(*attr_names)
    validates_with OptionalDecimalValidator, _merge_attributes(attr_names)
  end
end
