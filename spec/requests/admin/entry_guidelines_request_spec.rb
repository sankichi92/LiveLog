require 'rails_helper'

RSpec.describe 'admin/entry_guidelines request:', type: :request do
  let(:admin) { create(:admin) }

  before do
    log_in_as admin
  end

  describe 'GET /admin/lives/:live_id/entry_guideline/new' do
    let(:live) { create(:live, :unpublished) }

    it 'responds 200' do
      get new_admin_live_entry_guideline_path(live)

      expect(response).to have_http_status :ok
    end
  end

  describe 'POST /admin/lives/:live_id/entry_guideline' do
    let(:live) { create(:live, :unpublished) }
    let(:params) do
      {
        entry_guideline: {
          deadline: deadline,
          notes: '',
        },
      }
    end

    context 'with valid params' do
      let(:deadline) { Time.zone.now }

      it 'creates an entry_guideline and redirect_to /admin/lives' do
        post admin_live_entry_guideline_path(live), params: params

        expect(live.entry_guideline).to be_persisted
        expect(response).to redirect_to admin_lives_path(year: live.date.nendo)
      end
    end

    context 'with invalid params' do
      let(:deadline) { nil }

      it 'responds 422' do
        post admin_live_entry_guideline_path(live), params: params

        expect(live.entry_guideline).to be_nil
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'GET /admin/lives/:live_id/entry_guideline/edit' do
    let(:live) { create(:live, :unpublished, :with_entry_guideline) }

    it 'responds 200' do
      get edit_admin_live_entry_guideline_path(live)

      expect(response).to have_http_status :ok
    end
  end

  describe 'PATCH /admin/lives/:live_id/entry_guideline' do
    let(:live) { create(:live, :unpublished, :with_entry_guideline) }
    let(:params) do
      {
        entry_guideline: {
          deadline: deadline,
          notes: live.entry_guideline.notes,
        },
      }
    end

    context 'with valid params' do
      let(:deadline) { Time.zone.now.change(usec: 0) }

      it 'updates the entry_guideline and redirects to /admin/lives' do
        patch admin_live_entry_guideline_path(live), params: params

        expect(live.entry_guideline.reload.deadline).to eq deadline
        expect(response).to redirect_to admin_lives_path(year: live.date.nendo)
      end
    end

    context 'with invalid params' do
      let(:deadline) { 1.day.since(live.date) }

      it 'responds 422' do
        patch admin_live_entry_guideline_path(live), params: params

        expect(live.entry_guideline.reload.deadline).not_to eq deadline
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end
end
