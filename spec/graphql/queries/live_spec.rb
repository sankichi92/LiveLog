require 'rails_helper'

RSpec.describe 'GraphQL query:', type: :graphql do
  describe 'live' do
    subject(:result) { LiveLogSchema.execute(query, variables: { id: live.id }, context: context) }

    let(:live) { create(:live) }
    let(:query) do
      <<~GRAPHQL
        query($id: ID!) {
          live(id: $id) {
            id
            date
            name
            place
            comment
          }
        }
      GRAPHQL
    end
    let(:context) { graphql_context(scope: scope) }
    let(:scope) { '' }

    it 'returns Live' do
      expect(result.to_h).not_to include 'errors'
      expect(result['data']['live']).to include 'id', 'date', 'name', 'place', 'comment'
    end

    context 'with albumUrl field' do
      let(:query) do
        <<~GRAPHQL
          query($id: ID!) {
            live(id: $id) {
              albumUrl
            }
          }
        GRAPHQL
      end

      it 'returns errors' do
        expect(result.to_h).to include 'errors'
      end

      context 'with read:lives scope' do
        let(:scope) { 'read:lives' }

        it 'returns albumUrl' do
          result = LiveLogSchema.execute(query, variables: { id: live.id }, context: context)

          expect(result.to_h).not_to include 'errors'
          expect(result['data']['live']['albumUrl']).to eq live.album_url
        end
      end
    end
  end
end
