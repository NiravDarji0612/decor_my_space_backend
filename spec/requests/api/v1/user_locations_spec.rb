# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'User Locations API', type: :request do
  let(:user)         { create(:user) }
  let(:other_user)   { create(:user) }
  let(:access_token) { JwtService.generate_tokens(user)[:access_token] }

  path '/api/v1/users/{id}/location' do
    parameter name: :id, in: :path, type: :integer, required: true

    post 'Update the current user location' do
      tags 'Geolocation'
      description 'Persists the user current coordinates and appends a row to the location history. ' \
                  'Authorisation: a user can only update their own location.'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :params, in: :body, schema: { '$ref' => '#/components/schemas/user_location_request' }

      response '200', 'location updated' do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 message: { type: :string,  example: 'Location updated successfully' }
               },
               required: %w[success message]

        let(:Authorization) { "Bearer #{access_token}" }
        let(:id)            { user.id }
        let(:params)        { { latitude: 23.0225, longitude: 72.5714, accuracy_m: 9.5 } }

        run_test! do
          user.reload
          expect(user.latitude.to_f).to be_within(0.0001).of(23.0225)
          expect(user.longitude.to_f).to be_within(0.0001).of(72.5714)
          expect(user.location_histories.count).to eq(1)
        end
      end

      response '403', 'cannot update another user location' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{access_token}" }
        let(:id)            { other_user.id }
        let(:params)        { { latitude: 23.0225, longitude: 72.5714 } }

        run_test!
      end

      response '422', 'invalid coordinates' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{access_token}" }
        let(:id)            { user.id }
        let(:params)        { { latitude: 120, longitude: 0 } }

        run_test!
      end

      response '422', 'missing coordinates' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{access_token}" }
        let(:id)            { user.id }
        let(:params)        { {} }

        run_test!
      end

      response '404', 'user not found' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{access_token}" }
        let(:id)            { 9_999_999 }
        let(:params)        { { latitude: 23.0, longitude: 72.5 } }

        run_test!
      end

      response '401', 'missing token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { '' }
        let(:id)            { user.id }
        let(:params)        { { latitude: 23.0, longitude: 72.5 } }

        run_test!
      end
    end
  end
end
