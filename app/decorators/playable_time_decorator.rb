# frozen_string_literal: true

module PlayableTimeDecorator
  def formatted_range
    "#{l(lower, format: :short)}〜#{l(upper, format: :short)}"
  end
end
