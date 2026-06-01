# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Payment Methods API', type: :request do
  let(:user)         { create(:user) }
  let(:access_token) { JwtService.generate_tokens(user)[:access_token] }

  path '/api/v1/payment_methods' do
    get 'List payment methods' do
      tags 'Payment methods'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'payment methods returned' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: {
                     payment_methods: { type: :array, items: { '$ref' => '#/components/schemas/payment_method' } }
                   }
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

    post 'Add a payment method' do
      tags 'Payment methods'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :params, in: :body, schema: { '$ref' => '#/components/schemas/payment_method_request' }

      response '201', 'payment method added' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: { payment_method: { '$ref' => '#/components/schemas/payment_method' } }
                 }
               }

        let(:Authorization) { "Bearer #{access_token}" }
        let(:params) do
          { payment_method: { kind: 'card', title: 'Visa ending 4242', last4: '4242' } }
        end

        run_test!
      end

      response '422', 'validation errors' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{access_token}" }
        let(:params) { { payment_method: { kind: 'card', title: '' } } }

        run_test!
      end
    end
  end

  path '/api/v1/payment_methods/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    delete 'Remove a payment method' do
      tags 'Payment methods'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'removed' do
        schema '$ref' => '#/components/schemas/success_response'

        let(:pm)            { user.payment_methods.create!(kind: :card, title: 'V', last4: '4242') }
        let(:Authorization) { "Bearer #{access_token}" }
        let(:id)            { pm.id }

        run_test!
      end

      response '404', 'not found' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{access_token}" }
        let(:id)            { 9_999_999 }

        run_test!
      end
    end
  end

  path '/api/v1/payment_methods/{id}/default' do
    parameter name: :id, in: :path, type: :integer, required: true

    patch 'Mark a payment method as default' do
      tags 'Payment methods'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'default updated' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: { payment_method: { '$ref' => '#/components/schemas/payment_method' } }
                 }
               }

        let(:pm)            { user.payment_methods.create!(kind: :card, title: 'V', last4: '4242') }
        let(:Authorization) { "Bearer #{access_token}" }
        let(:id)            { pm.id }

        run_test! do |response|
          expect(JSON.parse(response.body)['data']['payment_method']['is_default']).to be true
        end
      end

      response '404', 'not found' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{access_token}" }
        let(:id)            { 9_999_999 }

        run_test!
      end
    end
  end
end
