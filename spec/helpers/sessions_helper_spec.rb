require 'rails_helper'

RSpec.describe SessionsHelper, type: :helper do
  let(:user) { create(:user) }

  describe '#current_user' do
    context 'with session[:user_id]' do
      before { helper.log_in(user) }

      it 'returns the user' do
        expect(helper.current_user).to eq(user)
      end
    end

    context 'with valid remember token' do
      before { helper.remember(user) }

      it 'returns the user' do
        expect(helper.current_user).to eq(user)
      end
    end

    context 'with invalid remember token' do
      before do
        helper.remember(user)
        helper.cookies[:remember_token] = 'invalid token'
      end

      it 'returns nil' do
        expect(helper.current_user).to be_nil
      end
    end

    context 'without session or remember token' do
      it 'returns nil' do
        expect(helper.current_user).to be_nil
      end
    end
  end
end
