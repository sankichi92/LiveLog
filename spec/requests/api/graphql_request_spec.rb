require 'rails_helper'

RSpec.describe 'graphql request:', type: :request do
  describe 'GET /api/graphql' do
    let(:access_token) { stub_access_token }

    context 'with introspection query' do
      let(:query) do
        <<~GRAPHQL
          query IntrospectionQuery {
            __schema {
              queryType { name }
              mutationType { name }
              subscriptionType { name }
              types {
                ...FullType
              }
              directives {
                name
                description
                locations
                args {
                  ...InputValue
                }
              }
            }
          }

          fragment FullType on __Type {
            kind
            name
            description
            fields(includeDeprecated: true) {
              name
              description
              args {
                ...InputValue
              }
              type {
                ...TypeRef
              }
              isDeprecated
              deprecationReason
            }
            inputFields {
              ...InputValue
            }
            interfaces {
              ...TypeRef
            }
            enumValues(includeDeprecated: true) {
              name
              description
              isDeprecated
              deprecationReason
            }
            possibleTypes {
              ...TypeRef
            }
          }

          fragment InputValue on __InputValue {
            name
            description
            type { ...TypeRef }
            defaultValue
          }

          fragment TypeRef on __Type {
            kind
            name
            ofType {
              kind
              name
              ofType {
                kind
                name
                ofType {
                  kind
                  name
                  ofType {
                    kind
                    name
                    ofType {
                      kind
                      name
                      ofType {
                        kind
                        name
                        ofType {
                          kind
                          name
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        GRAPHQL
      end

      it 'responds 200 without errors' do
        post api_graphql_path, headers: { authorization: "Bearer #{access_token}" }, params: { query: query }
        response_body = JSON.parse(response.body)

        expect(response_body.keys).to contain_exactly 'data'
        expect(response).to have_http_status :ok
      end
    end

    context 'with default query' do
      let(:query) do
        <<~GRAPHQL
          query {
            lives(first: 3) {
              pageInfo {
                hasNextPage
                endCursor
              }
              edges {
                cursor
                node {
                  id
                  date
                  name
                  place
                  songs(first: 3) {
                    totalCount
                    nodes {
                      id
                      order
                      name
                      artist
                      original
                      players {
                        edges {
                          instrument
                          node {
                            id
                            joinedYear
                            name
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        GRAPHQL
      end

      it 'responds 200 without errors' do
        post api_graphql_path, headers: { authorization: "Bearer #{access_token}" }, params: { query: query }
        response_body = JSON.parse(response.body)

        expect(response_body.keys).to contain_exactly 'data'
        expect(response).to have_http_status :ok
      end
    end
  end
end
