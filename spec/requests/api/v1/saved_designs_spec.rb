# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Saved Designs API', type: :request do
  let(:user)    { create(:user) }
  let(:design)  { create(:design) }
  let(:access_token) { JwtService.generate_tokens(user)[:access_token] }

  path '/api/v1/saved_designs' do
    parameter name: :page,     in: :query, type: :integer, required: false
    parameter name: :per_page, in: :query, type: :integer, required: false

    get 'List saved designs (favorites)' do
      tags 'Favorites'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'favorites returned' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: {
                     saved_designs: { type: :array, items: { '$ref' => '#/components/schemas/saved_design' } }
                   }
                 },
                 meta: { '$ref' => '#/components/schemas/pagination_meta' }
               }

        before { create(:saved_design, user: user, design: design) }

        let(:Authorization) { "Bearer #{access_token}" }
        let(:page) { nil }
        let(:per_page) { nil }

        run_test! do |response|
          expect(JSON.parse(response.body)['data']['saved_designs'].size).to eq(1)
        end
      end

      response '401', 'missing token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { '' }
        let(:page) { nil }
        let(:per_page) { nil }

        run_test!
      end
    end

    post 'Save a design to favorites' do
      tags 'Favorites'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :params, in: :body, schema: { '$ref' => '#/components/schemas/saved_design_request' }

      response '201', 'design saved' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 message: { type: :string, example: 'Design saved' },
                 data: {
                   type: :object,
                   properties: { saved_design: { '$ref' => '#/components/schemas/saved_design' } }
                 }
               }

        let(:Authorization) { "Bearer #{access_token}" }
        let(:params) { { design_id: design.id } }

        run_test!
      end

      response '404', 'design not found' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{access_token}" }
        let(:params) { { design_id: 9_999_999 } }

        run_test!
      end

      response '401', 'missing token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { '' }
        let(:params) { { design_id: 1 } }

        run_test!
      end
    end
  end

  path '/api/v1/saved_designs/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    delete 'Remove a saved design' do
      tags 'Favorites'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'design removed' do
        schema '$ref' => '#/components/schemas/success_response'

        let(:saved)         { create(:saved_design, user: user, design: design) }
        let(:Authorization) { "Bearer #{access_token}" }
        let(:id)            { saved.id }

        run_test!
      end

      response '404', 'not found in user favorites' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{access_token}" }
        let(:id)            { 9_999_999 }

        run_test!
      end

      response '401', 'missing token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { '' }
        let(:id) { 1 }

        run_test!
      end
    end
  end
end
