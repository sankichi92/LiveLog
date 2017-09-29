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
  end

  describe 'as wrong user' do
    let(:user) { create(:user) }
    let(:wrong_user) { create(:user, email: 'wrong@example.com') }
    before { log_in_as user, capybara: false }

    describe 'submitting a GET request to the Users#edit action' do
      before { get edit_user_path(wrong_user) }
      specify { expect(response.body).not_to match(full_title('Edit user')) }
      specify { expect(response).to redirect_to(root_url) }
    end

    describe 'submitting a PATCH request to the Users#update action' do
      before { patch user_path(wrong_user) }
      specify { expect(response).to redirect_to(root_path) }
    end

    describe 'in the Songs Controller' do

      describe 'visiting a draft song he/she will not play' do
        let(:draft_live) { create(:live, date: 1.month.from_now) }
        let(:draft_song_user_will_not_play) { create(:song, live: draft_live) }

        it 'should be redirected to root' do
          get song_path(draft_song_user_will_not_play)
          expect(response).to redirect_to(root_path)
        end
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
