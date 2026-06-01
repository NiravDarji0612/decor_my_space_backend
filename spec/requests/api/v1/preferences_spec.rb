# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Preferences API', type: :request do
  let(:user)         { create(:user) }
  let(:access_token) { JwtService.generate_tokens(user)[:access_token] }

  path '/api/v1/preferences' do
    get 'Get user preferences' do
      tags 'Preferences'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'preferences returned' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: { preferences: { '$ref' => '#/components/schemas/user_preference' } }
                 }
               }

        let(:Authorization) { "Bearer #{access_token}" }

        run_test!
      end

      response '401', 'missing token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { '' }

        run_test!
      end
    end

    patch 'Update user preferences' do
      tags 'Preferences'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :params, in: :body, schema: { '$ref' => '#/components/schemas/preferences_request' }

      response '200', 'preferences updated' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: { preferences: { '$ref' => '#/components/schemas/user_preference' } }
                 }
               }

        let(:Authorization) { "Bearer #{access_token}" }
        let(:params) { { preferences: { dark_mode: true, locale: 'ar', currency: 'AED' } } }

        run_test! do |response|
          prefs = JSON.parse(response.body)['data']['preferences']
          expect(prefs['dark_mode']).to be true
          expect(prefs['locale']).to eq('ar')
          expect(prefs['currency']).to eq('AED')
        end
      end

      response '422', 'invalid locale' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{access_token}" }
        let(:params) { { preferences: { locale: 'zz' } } }

        run_test!
      end
    end
  end
end
