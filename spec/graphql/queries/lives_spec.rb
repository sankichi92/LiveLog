# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GraphQL query: lives', type: :graphql do
  subject(:result) { LiveLogSchema.execute(query, variables: variables) }

  let(:query) do
    <<~GRAPHQL
      query($year: Int) {
        lives(year: $year) {
          nodes {
            id
          }
        }
      }
    GRAPHQL
  end
  let(:variables) { {} }

  before do
    3.times do |i|
      create(:live, date: Date.new(2021, i + 1, 1))
    end
  end

  it 'returns lives' do
    expect(result.to_h).not_to include('errors')
    expect(result['data']['lives']['nodes'].size).to eq 3
  end

  context 'with year' do
    let(:variables) { { year: year } }
    let(:year) { 2022 }

    before do
      create(:live, date: Date.new(2022, 4, 1))
    end

    it 'returns lives that held on given year' do
      expect(result.to_h).not_to include('errors')
      expect(result['data']['lives']['nodes'].size).to eq 1
    end
  end
end
