module PlayingDecorator
  def instrument_and_name
    if inst.present?
      "#{inst}.#{member.short_name}"
    else
      member.short_name
    end
  end
end
