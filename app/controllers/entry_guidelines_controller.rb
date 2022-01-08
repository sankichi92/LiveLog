# frozen_string_literal: true

class EntryGuidelinesController < ApplicationController
  include ActionView::Helpers::TextHelper

  def show(live_id)
    entry_guideline = EntryGuideline.find_by!(live_id:)
    render json: { deadline: l(entry_guideline.deadline), notes: simple_format(entry_guideline.notes) }
  end
end
