# frozen_string_literal: true

class DocsController < ApplicationController
  def privacy
    markdown = Rails.root.join('docs/privacy.md').read
    @html = Commonmarker.to_html(markdown)
  end
end
