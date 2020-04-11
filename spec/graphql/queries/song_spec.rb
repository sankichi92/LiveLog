require 'rails_helper'

RSpec.describe 'GraphQL query:', type: :graphql do
  describe 'song' do
    subject(:result) { LiveLogSchema.execute(query, variables: { id: song.id }, context: context) }

    let(:song) { create(:song, visibility: :only_logged_in_users, youtube_url: 'https://www.youtube.com/watch?v=2TL90rxt9bo') }
    let(:query) do
      <<~GRAPHQL
        query($id: ID!) {
          song(id: $id) {
            id
            time
            order
            name
            artist
            original
            comment
            live {
              id
              date
              name
            }
          }
        }
      GRAPHQL
    end
    let(:context) { graphql_context(scope: scope) }
    let(:scope) { '' }

    it 'returns Song' do
      expect(result.to_h).not_to include 'errors'
      expect(result['data']['song']).to include 'id', 'time', 'order', 'name', 'artist', 'original', 'comment', 'live'
    end

    context 'with youtubeUrl field' do
      let(:query) do
        <<~GRAPHQL
          query($id: ID!) {
            song(id: $id) {
              youtubeUrl
            }
          }
        GRAPHQL
      end

      it 'returns empty youtubeUrl' do
        expect(result['data']['song']['youtubeUrl']).to be_nil
      end

      context 'with read:songs scope' do
        let(:scope) { 'read:songs' }

        it 'returns youtubeUrl' do
          expect(result['data']['song']['youtubeUrl']).to eq song.youtube_url
        end
      end
    end
  end
end
