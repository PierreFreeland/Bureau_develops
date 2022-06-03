# A monkey-patch that allows you to use comma as decimal separator in ActiveRecord
# Notice for rails 5.0: in Rails 5.0 module Type with all nested classes is moved into ActiveModel,
# so don't forget to substitute 'module ActiveRecord' with 'module ActiveModel' after update
module ActiveRecord
  module Type
    class Decimal
      private

        alias_method :cast_value_without_comma_separator, :cast_value

        def cast_value(value)
          value = value.tr(',', '.') if value.is_a?(::String)
          cast_value_without_comma_separator(value)
        end
    end

    class Float
      private

        alias_method :cast_value_without_comma_separator, :cast_value

        def cast_value(value)
          value = value.tr(',', '.') if value.is_a?(::String)
          cast_value_without_comma_separator(value)
        end
    end
  end
end

## Since NumericalityValidator uses for validation value before typecast
## we need to patch it too.
module ActiveModel
  module Validations
    class NumericalityValidator
      protected

        def parse_raw_value_as_a_number(raw_value)
          raw_value = raw_value.tr(',', '.') if raw_value.is_a?(::String)
          Kernel.Float(raw_value) if raw_value !~ /\A0[xX]/
        end
    end
  end
end
