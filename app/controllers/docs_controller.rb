# frozen_string_literal: true

class DocsController < ApplicationController
  def privacy
    markdown = Rails.root.join('docs/privacy.md').read
    @html = Kramdown::Document.new(markdown).to_html
  end
end
