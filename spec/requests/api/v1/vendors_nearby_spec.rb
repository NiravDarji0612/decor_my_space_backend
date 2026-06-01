# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Nearby Vendors API', type: :request do
  let(:user)         { create(:user) }
  let(:access_token) { JwtService.generate_tokens(user)[:access_token] }

  # Ahmedabad: 23.0225, 72.5714
  let!(:close_vendor) do
    create(:decorator, name: 'Close Studio',
                       latitude: 23.0300, longitude: 72.5800,
                       category: 'wedding', rating_avg: 4.7, open: true, active: true)
  end
  let!(:medium_vendor) do
    create(:decorator, name: 'Medium Studio',
                       latitude: 23.1000, longitude: 72.6500,
                       category: 'birthday', rating_avg: 4.2, open: true, active: true)
  end
  let!(:far_vendor) do
    # ~450 km away (Mumbai-ish)
    create(:decorator, name: 'Far Studio',
                       latitude: 19.0760, longitude: 72.8777,
                       category: 'wedding', rating_avg: 4.9, open: false, active: true)
  end

  path '/api/v1/vendors/nearby' do
    parameter name: :latitude,   in: :query, type: :number, required: true,  example: 23.0225
    parameter name: :longitude,  in: :query, type: :number, required: true,  example: 72.5714
    parameter name: :radius,     in: :query, type: :number, required: false, description: 'Radius in km (default 5).'
    parameter name: :category,   in: :query, type: :string, required: false
    parameter name: :min_rating, in: :query, type: :number, required: false
    parameter name: :open,       in: :query, type: :boolean, required: false
    parameter name: :page,       in: :query, type: :integer, required: false
    parameter name: :per_page,   in: :query, type: :integer, required: false

    get 'Fetch vendors within a radius, sorted by distance' do
      tags 'Geolocation'
      description 'Uses PostGIS ST_DWithin / ST_Distance when available; otherwise falls back to Haversine SQL.'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'vendors returned, sorted by distance' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: {
                     vendors: { type: :array, items: { '$ref' => '#/components/schemas/nearby_vendor' } }
                   }
                 },
                 meta: { '$ref' => '#/components/schemas/nearby_meta' }
               }

        let(:Authorization) { "Bearer #{access_token}" }
        let(:latitude)  { 23.0225 }
        let(:longitude) { 72.5714 }
        let(:radius)    { 25 }
        let(:category)   { nil }
        let(:min_rating) { nil }
        let(:open)       { nil }
        let(:page)       { nil }
        let(:per_page)   { nil }

        run_test! do |response|
          body    = JSON.parse(response.body)
          vendors = body['data']['vendors']
          names   = vendors.map { |v| v['name'] }

          expect(names).to include('Close Studio', 'Medium Studio')
          expect(names).not_to include('Far Studio') # > 25 km
          # Distances should be ascending
          distances = vendors.map { |v| v['distance_m'] }
          expect(distances).to eq(distances.sort)
        end
      end

      response '200', 'empty when no vendors in radius' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: {
                     vendors: { type: :array, items: { '$ref' => '#/components/schemas/nearby_vendor' } }
                   }
                 },
                 meta: { '$ref' => '#/components/schemas/nearby_meta' }
               }

        let(:Authorization) { "Bearer #{access_token}" }
        let(:latitude)  { 0.0 }
        let(:longitude) { 0.0 }
        let(:radius)    { 1 }
        let(:category) { nil }
        let(:min_rating) { nil }
        let(:open) { nil }
        let(:page) { nil }
        let(:per_page) { nil }

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body['data']['vendors']).to eq([])
          expect(body['meta']['total']).to eq(0)
        end
      end

      response '422', 'invalid coordinates' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{access_token}" }
        let(:latitude)  { 999 }
        let(:longitude) { 72.5 }
        let(:radius)    { nil }
        let(:category) { nil }
        let(:min_rating) { nil }
        let(:open) { nil }
        let(:page) { nil }
        let(:per_page) { nil }

        run_test!
      end

      response '422', 'missing coordinates' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{access_token}" }
        let(:latitude)  { nil }
        let(:longitude) { nil }
        let(:radius)    { nil }
        let(:category) { nil }
        let(:min_rating) { nil }
        let(:open) { nil }
        let(:page) { nil }
        let(:per_page) { nil }

        run_test!
      end

      response '401', 'missing token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { '' }
        let(:latitude)  { 23.0225 }
        let(:longitude) { 72.5714 }
        let(:radius)    { nil }
        let(:category) { nil }
        let(:min_rating) { nil }
        let(:open) { nil }
        let(:page) { nil }
        let(:per_page) { nil }

        run_test!
      end
    end
  end
end
