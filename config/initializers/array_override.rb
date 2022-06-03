class Array
  def join_without_blank(separator = nil)
    reject(&:blank?).join(separator)
  end

  def except(*values)
    self - values
  end

  # convert enumerize array to key-value hash
  # [["Prestataire", "service_provider"], ["Exécutive", "executive"], ["Expert", "expert"]]
  # [{value: "service_provider", label: "Prestataire"}, ...]
  def to_hash_options(value_key_label: :value, text_key_label: :label)
    reduce([]) do |accumulator, (label, value)|
      accumulator.push({
                           "#{value_key_label}": value,
                           "#{text_key_label}": label,
                       })
    end
  end
end
