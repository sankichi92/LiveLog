require 'rails_helper'

RSpec.describe "Lives", type: :request do
  describe "GET /lives" do
    it "works! (now write some real specs)" do
      get lives_path
      expect(response).to have_http_status(200)
    end
  end
end
