# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Profile API', type: :request do
  let!(:user) { create(:user, :vendor, email: 'profile@example.com') }

  path '/api/v1/profile' do
    get 'Get current user profile' do
      tags 'Profile'
      description 'Returns the authenticated user\'s profile information. Requires a valid JWT access token.'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'profile retrieved' do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 data: {
                   type: :object,
                   properties: {
                     user: { '$ref' => '#/components/schemas/user' }
                   }
                 }
               }

        let(:Authorization) do
          token = JwtService.encode({ user_id: user.id })
          "Bearer #{token}"
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['success']).to be true
          expect(json['data']['user']['email']).to eq('profile@example.com')
          expect(json['data']['user']['account_type']).to eq('vendor')
        end
      end

      response '401', 'missing token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { '' }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['error']).to eq('Missing authorization token')
        end
      end

      response '401', 'invalid token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { 'Bearer invalid.token.here' }

        run_test!
      end
    end
  end
end
