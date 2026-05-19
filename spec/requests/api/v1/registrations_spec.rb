# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Registration API', type: :request do
  path '/api/v1/register' do
    post 'Create a new user account' do
      tags 'Authentication'
      description 'Registers a new user with the provided details and returns JWT tokens.'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :params, in: :body, schema: { '$ref' => '#/components/schemas/registration_request' }

      response '201', 'account created successfully' do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 message: { type: :string, example: 'Account created successfully' },
                 data: {
                   type: :object,
                   properties: {
                     user: { '$ref' => '#/components/schemas/user' },
                     tokens: { '$ref' => '#/components/schemas/tokens' }
                   }
                 }
               }

        let(:params) do
          {
            user: {
              full_name: 'Alice Wonder',
              email: 'alice@example.com',
              phone: '+15550003333',
              password: 'securepass123',
              account_type: 'customer',
              accepted_terms: true
            }
          }
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['success']).to be true
          expect(json['data']['user']['email']).to eq('alice@example.com')
          expect(json['data']['tokens']['access_token']).to be_present
        end
      end

      response '201', 'vendor account created' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: {
                     user: { '$ref' => '#/components/schemas/user' },
                     tokens: { '$ref' => '#/components/schemas/tokens' }
                   }
                 }
               }

        let(:params) do
          {
            user: {
              full_name: 'Bob Vendor',
              email: 'bob@example.com',
              phone: '+15550004444',
              password: 'securepass123',
              account_type: 'vendor',
              accepted_terms: true
            }
          }
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']['user']['account_type']).to eq('vendor')
        end
      end

      response '422', 'validation errors' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:params) do
          {
            user: {
              full_name: '',
              email: 'invalid',
              phone: '',
              password: 'short',
              account_type: 'customer',
              accepted_terms: false
            }
          }
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['success']).to be false
          expect(json['errors']).to be_present
        end
      end

      response '422', 'duplicate email' do
        schema '$ref' => '#/components/schemas/error_response'

        before { create(:user, email: 'taken@example.com') }

        let(:params) do
          {
            user: attributes_for(:user, email: 'taken@example.com', phone: '+15550008888')
          }
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors']).to include('Email has already been taken')
        end
      end
    end
  end
end
