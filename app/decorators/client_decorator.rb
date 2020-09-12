# frozen_string_literal: true

module ClientDecorator
  def url_host
    URI.parse(url).host if url.present?
  end
end
