# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GraphQL query: lives', type: :graphql do
  subject(:result) { LiveLogSchema.execute(query) }

  let(:query) do
    <<~GRAPHQL
      query {
        lives {
          nodes {
            id
          }
        }
      }
    GRAPHQL
  end

  before do
    create_list(:live, 3)
  end

  it 'returns lives' do
    expect(result.to_h).not_to include('errors')
    expect(result['data']['lives']['nodes'].size).to eq 3
  end
end
