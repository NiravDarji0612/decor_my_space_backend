# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Addresses API', type: :request do
  let(:user)         { create(:user) }
  let(:access_token) { JwtService.generate_tokens(user)[:access_token] }

  path '/api/v1/addresses' do
    get 'List addresses for current user' do
      tags 'Addresses'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'addresses returned' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: {
                     addresses: { type: :array, items: { '$ref' => '#/components/schemas/address' } }
                   }
                 }
               }

        before { create(:address, user: user) }

        let(:Authorization) { "Bearer #{access_token}" }

        run_test!
      end

      response '401', 'missing token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { '' }

        run_test!
      end
    end

    post 'Create an address' do
      tags 'Addresses'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :params, in: :body, schema: { '$ref' => '#/components/schemas/address_request' }

      response '201', 'address created' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: { address: { '$ref' => '#/components/schemas/address' } }
                 }
               }

        let(:Authorization) { "Bearer #{access_token}" }
        let(:params) do
          { address: { label: 'Home', recipient_name: 'Riya Shah', line1: '12 MG Road',
                       city: 'Pune', state: 'MH', postal_code: '411001',
                       country: 'IN', phone: '+919812345678' } }
        end

        run_test!
      end

      response '422', 'validation errors' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{access_token}" }
        let(:params) { { address: { label: '', recipient_name: '', line1: '', country: '', phone: '' } } }

        run_test!
      end

      response '401', 'missing token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { '' }
        let(:params) { { address: {} } }

        run_test!
      end
    end
  end

  path '/api/v1/addresses/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    get 'Get an address' do
      tags 'Addresses'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'address returned' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: { address: { '$ref' => '#/components/schemas/address' } }
                 }
               }

        let(:address)       { create(:address, user: user) }
        let(:Authorization) { "Bearer #{access_token}" }
        let(:id)            { address.id }

        run_test!
      end

      response '404', 'address not found' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{access_token}" }
        let(:id)            { 9_999_999 }

        run_test!
      end
    end

    patch 'Update an address' do
      tags 'Addresses'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :params, in: :body, schema: { '$ref' => '#/components/schemas/address_request' }

      response '200', 'address updated' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: { address: { '$ref' => '#/components/schemas/address' } }
                 }
               }

        let(:address)       { create(:address, user: user) }
        let(:Authorization) { "Bearer #{access_token}" }
        let(:id)            { address.id }
        let(:params)        { { address: { line1: 'New Street 99' } } }

        run_test!
      end

      response '404', 'address not found' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{access_token}" }
        let(:id)            { 9_999_999 }
        let(:params)        { { address: { line1: 'X' } } }

        run_test!
      end
    end

    delete 'Delete an address' do
      tags 'Addresses'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'address removed' do
        schema '$ref' => '#/components/schemas/success_response'

        let(:address)       { create(:address, user: user) }
        let(:Authorization) { "Bearer #{access_token}" }
        let(:id)            { address.id }

        run_test!
      end

      response '404', 'address not found' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{access_token}" }
        let(:id)            { 9_999_999 }

        run_test!
      end
    end
  end

  path '/api/v1/addresses/{id}/default' do
    parameter name: :id, in: :path, type: :integer, required: true

    patch 'Mark an address as default' do
      tags 'Addresses'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'default updated' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: { address: { '$ref' => '#/components/schemas/address' } }
                 }
               }

        let(:address)       { create(:address, user: user) }
        let(:Authorization) { "Bearer #{access_token}" }
        let(:id)            { address.id }

        run_test! do |response|
          expect(JSON.parse(response.body)['data']['address']['is_default']).to be true
        end
      end

      response '404', 'address not found' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{access_token}" }
        let(:id)            { 9_999_999 }

        run_test!
      end
    end
  end
end
