require 'rails_helper'

RSpec.describe "Authentication", type: :request do

  describe 'for non-signed-in users' do
    let(:user) { create(:user) }

    describe 'in the Users controller' do

      describe 'visiting the edit page' do
        before { get edit_user_path(user) }
        specify { expect(response).to redirect_to(login_path) }
      end

      describe 'submitting to the update action' do
        before { patch user_path(user) }
        specify { expect(response).to redirect_to(login_path) }
      end
    end

    describe 'in the Songs controller' do
      let(:song) { create(:song, live: create(:live)) }

      describe 'submitting to the create action' do
        before { post songs_path }
        specify { expect(response).to redirect_to(login_path) }
      end

      describe 'submitting to the update action' do
        before { patch song_path(song) }
        specify { expect(response).to redirect_to(login_path) }
      end
    end

    describe 'in the Entries controller' do
      let(:live) { create(:draft_live) }

      describe 'visiting the new entry page' do
        before { get new_live_entry_path(live) }
        specify { expect(response).to redirect_to(login_path) }
      end

      describe 'submitting to the create action' do
        before { post live_entries_path(live) }
        specify { expect(response).to redirect_to(login_path) }
      end
    end
  end

  describe 'as wrong user' do
    let(:user) { create(:user) }
    let(:wrong_user) { create(:user, email: 'wrong@example.com') }
    before { log_in_as user, capybara: false }

    describe 'in the Users controller' do

      describe 'visiting the edit page' do
        before { get edit_user_path(wrong_user) }
        specify { expect(response.body).not_to match(full_title('Edit user')) }
        specify { expect(response).to redirect_to(root_url) }
      end

      describe 'submitting to the update action' do
        before { patch user_path(wrong_user) }
        specify { expect(response).to redirect_to(root_path) }
      end
    end

    describe 'in the Songs Controller' do
      let(:live) { create(:live) }
      let(:song) { create(:song, live: live, user: wrong_user) }

      describe 'visiting the draft song page' do
        let(:live) { create(:draft_live) }
        before { get song_path(song) }
        specify { expect(response).to redirect_to(root_path) }
      end

      describe 'visiting the edit page' do
        before { get edit_song_path(song) }
        specify { expect(response).to redirect_to(root_path) }
      end

      describe 'submitting to the update action' do
        before { patch song_path(song) }
        specify { expect(response).to redirect_to(root_path) }
      end
    end
  end

  describe 'as non-admin user' do
    let(:user) { create(:user) }
    let(:non_admin) { create(:user) }

    before { log_in_as non_admin, capybara: false }

    describe 'in the Users controller' do

      describe 'submitting a DELETE request to the destroy action' do
        before { delete user_path(user) }
        specify { expect(response).to redirect_to(root_path) }
      end
    end

    describe 'in the Lives controller' do
      let(:live) { create(:live) }

      describe 'submitting to the create action' do
        before { post lives_path }
        specify { expect(response).to redirect_to(root_path) }
      end

      describe 'submitting to the update action' do
        before { patch live_path(live) }
        specify { expect(response).to redirect_to(root_path) }
      end

      describe 'submitting to the destroy action' do
        before { delete live_path(live) }
        specify { expect(response).to redirect_to(root_path) }
      end
    end

    describe 'in the Songs controller' do
      let(:song) { create(:song, live: create(:live)) }

      describe 'submitting to the destroy action' do
        before { delete song_path(song) }
        specify { expect(response).to redirect_to(root_path) }
      end
    end
  end
end
