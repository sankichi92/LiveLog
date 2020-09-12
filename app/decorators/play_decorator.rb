# frozen_string_literal: true

module PlayDecorator
  def instrument_and_name
    if instrument.present?
      "#{instrument}.#{member.name}"
    else
      member.name
    end
  end
end
