# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Home API', type: :request do
  let(:user) { create(:user) }

  path '/api/v1/home/feed' do
    parameter name: :city, in: :query, type: :string, required: false

    get 'Aggregated home feed' do
      tags 'Home'
      description 'Returns categories, featured designs, trending designs and nearby vendors.'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'feed returned' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: {
                     categories:       { type: :array, items: { '$ref' => '#/components/schemas/category' } },
                     featured_designs: { type: :array, items: { '$ref' => '#/components/schemas/design_summary' } },
                     trending_designs: { type: :array, items: { '$ref' => '#/components/schemas/design_summary' } },
                     nearby_vendors:   { type: :array, items: { '$ref' => '#/components/schemas/decorator' } }
                   }
                 }
               }

        let(:Authorization) { "Bearer #{JwtService.generate_tokens(user)[:access_token]}" }
        let(:city) { nil }

        run_test!
      end

      response '401', 'missing token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { '' }
        let(:city) { nil }

        run_test!
      end
    end
  end
end
