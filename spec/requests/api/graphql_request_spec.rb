require 'rails_helper'

RSpec.describe 'graphql request:', type: :request do
  describe 'GET /api/graphql' do
    let(:access_token) { stub_access_token }
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

    it 'responds 200' do
      post api_graphql_path, headers: { authorization: "Bearer #{access_token}" }, params: { query: query }
      response_body = JSON.parse(response.body)

      expect(response).to have_http_status :ok
      expect(response_body).to include 'data'
      expect(response_body).not_to include 'errors'
    end
  end
end
