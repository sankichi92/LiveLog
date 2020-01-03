module PlayDecorator
  def instrument_and_name
    if inst.present?
      "#{inst}.#{member.name}"
    else
      member.name
    end
  end
end
