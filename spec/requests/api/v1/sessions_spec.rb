# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Sessions API', type: :request do
  let!(:user) { create(:user, email: 'login@example.com') }

  path '/api/v1/login' do
    post 'Authenticate a user' do
      tags 'Authentication'
      description 'Validates credentials and returns JWT access and refresh tokens.'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :params, in: :body, schema: { '$ref' => '#/components/schemas/login_request' }

      response '200', 'login successful' do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 message: { type: :string, example: 'Logged in successfully' },
                 data: {
                   type: :object,
                   properties: {
                     user: { '$ref' => '#/components/schemas/user' },
                     tokens: { '$ref' => '#/components/schemas/tokens' }
                   }
                 }
               }

        let(:params) { { session: { email: 'login@example.com', password: 'password123' } } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['success']).to be true
          expect(json['data']['user']['email']).to eq('login@example.com')
          expect(json['data']['tokens']['access_token']).to be_present
          expect(json['data']['tokens']['refresh_token']).to be_present
        end
      end

      response '200', 'login is case-insensitive for email' do
        let(:params) { { session: { email: 'LOGIN@EXAMPLE.COM', password: 'password123' } } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['success']).to be true
        end
      end

      response '401', 'invalid password' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:params) { { session: { email: 'login@example.com', password: 'wrongpassword' } } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['success']).to be false
          expect(json['error']).to eq('Invalid email or password')
        end
      end

      response '401', 'non-existent user' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:params) { { session: { email: 'nobody@example.com', password: 'password123' } } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['error']).to eq('Invalid email or password')
        end
      end
    end
  end

  path '/api/v1/refresh' do
    post 'Refresh access token' do
      tags 'Authentication'
      description 'Exchanges a valid refresh token for new access and refresh tokens.'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'tokens refreshed successfully' do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 message: { type: :string, example: 'Token refreshed successfully' },
                 data: {
                   type: :object,
                   properties: {
                     tokens: { '$ref' => '#/components/schemas/tokens' }
                   }
                 }
               }

        let(:Authorization) do
          token = JwtService.encode({ user_id: user.id, type: 'refresh' }, expiry: 30.days)
          "Bearer #{token}"
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['success']).to be true
          expect(json['data']['tokens']['access_token']).to be_present
        end
      end

      response '401', 'access token used instead of refresh token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) do
          token = JwtService.encode({ user_id: user.id })
          "Bearer #{token}"
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['error']).to eq('Invalid token type. Use refresh token.')
        end
      end

      response '401', 'no token provided' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { '' }

        run_test!
      end
    end
  end

  path '/api/v1/logout' do
    delete 'Log out current session' do
      tags 'Authentication'
      description 'Statelessly acknowledges logout. Client should discard tokens. ' \
                  'Reserved for future server-side JWT revocation.'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'logout acknowledged' do
        schema '$ref' => '#/components/schemas/success_response'

        let(:Authorization) { "Bearer #{JwtService.generate_tokens(user)[:access_token]}" }

        run_test! do |response|
          expect(JSON.parse(response.body)['success']).to be true
        end
      end

      response '401', 'missing token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { '' }

        run_test!
      end
    end
  end
end
