currencies = [
  {
    priority:            100,
    iso_code:            "NOK",
    iso_numeric:         "578",
    name:                "Norwegian Krone",
    symbol:              "NOK",
    subunit:             "Øre",
    subunit_to_unit:     100,
    decimal_mark:        ",",
    thousands_separator: "."
  },

  {
    priority:            100,
    iso_code:            "DKK",
    iso_numeric:         "208",
    name:                "Danish Krone",
    symbol:              "DKK",
    subunit:             "Øre",
    subunit_to_unit:     50,
    decimal_mark:        ",",
    thousands_separator: "."
  },

  {
    priority:            100,
    iso_code:            "XAF",
    iso_numeric:         "950",
    name:                "Central African Cfa Franc",
    symbol:              "XAF",
    subunit:             "Centime",
    subunit_to_unit:     100,
    decimal_mark:        ".",
    thousands_separator: ","
  },

  {
    priority:            100,
    iso_code:            "XOF",
    iso_numeric:         "952",
    name:                "West African Cfa Franc",
    symbol:              "XOF",
    subunit:             "Centime",
    subunit_to_unit:     100,
    decimal_mark:        ".",
    thousands_separator: ","
  },

  {
    priority:            100,
    iso_code:            "XPF",
    iso_numeric:         "953",
    name:                "Cfp Franc",
    symbol:              "XPF",
    subunit:             "Centime",
    subunit_to_unit:     100,
    decimal_mark:        ".",
    thousands_separator: ","
  }

]

currencies.each { |curr| Money::Currency.register curr }
