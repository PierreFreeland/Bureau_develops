module ActiveModel
  class Errors
    # Returns +true+ if an error on the attribute with the given message is
    # present, or +false+ otherwise. +message+ is treated the same as for +add+.
    #
    #   person.errors.add :age
    #   person.errors.add :name, :too_long, { count: 25 }
    #   person.errors.of_kind? :age                                            # => true
    #   person.errors.of_kind? :name                                           # => false
    #   person.errors.of_kind? :name, :too_long                                # => true
    #   person.errors.of_kind? :name, "is too long (maximum is 25 characters)" # => true
    #   person.errors.of_kind? :name, :not_too_long                            # => false
    #   person.errors.of_kind? :name, "is too long"                            # => false
    def of_kind?(attribute, message = :invalid)
      message = message.call if message.respond_to?(:call)

      if message.is_a? Symbol
        details[attribute.to_sym].map { |e| e[:error] }.include? message
      else
        self[attribute].include? message
      end
    end
  end
end
