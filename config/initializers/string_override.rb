class String
  # convert '#abcd' to 'abcd'
  def to_css_id
    sub('#','')
  end
end
