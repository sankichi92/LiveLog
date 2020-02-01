class DocsController < ApplicationController
  def privacy
    markdown = Rails.root.join('docs/privacy.md').read
    @html = CommonMarker.render_html(markdown)
  end
end
