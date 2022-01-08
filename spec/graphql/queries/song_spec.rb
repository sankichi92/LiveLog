# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GraphQL query: song', type: :graphql do
  subject(:result) { LiveLogSchema.execute(query, variables:, context:) }

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
          }
          players {
            edges {
              instrument
              node {
                id
              }
            }
          }
        }
      }
    GRAPHQL
  end
  let(:variables) { { id: LiveLogSchema.id_from_object(song, Types::SongType) } }
  let(:context) { { auth_payload: { scope: } } }

  let(:song) do
    create(
      :song,
      visibility: :only_logged_in_users,
      youtube_url: 'https://www.youtube.com/watch?v=2TL90rxt9bo',
      audio: Rack::Test::UploadedFile.new("#{::Rails.root}/spec/fixtures/files/audio.mp3", 'audio/mpeg'),
    )
  end
  let!(:play) { create(:play, song:) }
  let(:scope) { '' }

  it 'returns a song' do
    expect(result.to_h).not_to include('errors')
    expect(result['data'].deep_symbolize_keys).to match(
      {
        song: {
          id: String,
          time: song.time_str,
          order: song.position,
          name: song.name,
          artist: song.artist,
          original: song.original?,
          comment: song.comment,
          live: {
            id: String,
          },
          players: {
            edges: [
              {
                instrument: play.instrument,
                node: {
                  id: String,
                },
              },
            ],
          },
        },
      },
    )
  end

  context 'with youtubeUrl and audioUrl' do
    let(:query) do
      <<~GRAPHQL
        query($id: ID!) {
          song(id: $id) {
            youtubeUrl
            audioUrl
          }
        }
      GRAPHQL
    end

    it 'returns empty urls' do
      expect(result.to_h).not_to include('errors')
      expect(result['data']['song']['youtubeUrl']).to be_nil
      expect(result['data']['song']['audioUrl']).to be_nil
    end

    context 'with read:songs scope' do
      let(:scope) { 'read:songs' }

      it 'returns youtubeUrl' do
        expect(result.to_h).not_to include('errors')
        expect(result['data']['song']['youtubeUrl']).to eq song.youtube_url
        expect(result['data']['song']['audioUrl']).to be_present
      end
    end
  end
end
