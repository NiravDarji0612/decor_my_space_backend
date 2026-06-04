# frozen_string_literal: true

require 'rails_helper'

# End-to-end coverage for the `show_records_based_on_location` flag across
# the three listing endpoints it affects. The test environment uses
# :null_store so we stub FeatureFlag directly instead of toggling via cache.
RSpec.describe 'show_records_based_on_location feature flag', type: :request do
  let(:user)         { create(:user, city: 'Pune') }
  let(:access_token) { JwtService.generate_tokens(user)[:access_token] }
  let(:auth_headers) { { 'Authorization' => "Bearer #{access_token}" } }

  let!(:pune_vendor) do
    create(:decorator, name: 'Pune Studio', city: 'Pune',
                       latitude: 18.5204, longitude: 73.8567,
                       rating_avg: 4.2, review_count: 5, active: true)
  end
  let!(:mumbai_vendor) do
    create(:decorator, name: 'Mumbai Studio', city: 'Mumbai',
                       latitude: 19.0760, longitude: 72.8777,
                       rating_avg: 4.9, review_count: 100, active: true)
  end

  def stub_flag(value)
    allow(FeatureFlag).to receive(:enabled?)
      .with(:show_records_based_on_location, default: true)
      .and_return(value)
  end

  describe 'GET /api/v1/vendors/nearby' do
    context 'when flag is ON' do
      before { stub_flag(true) }

      it 'returns 422 when latitude/longitude are missing' do
        get '/api/v1/vendors/nearby', headers: auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'filters by radius around the given coordinates' do
        get '/api/v1/vendors/nearby',
            params: { latitude: 18.5204, longitude: 73.8567, radius: 5 },
            headers: auth_headers
        expect(response).to have_http_status(:ok)
        names = JSON.parse(response.body).dig('data', 'vendors').map { |v| v['name'] }
        expect(names).to include('Pune Studio')
        expect(names).not_to include('Mumbai Studio')
      end
    end

    context 'when flag is OFF' do
      before { stub_flag(false) }

      it 'returns 200 with vendors even when lat/lng are omitted' do
        get '/api/v1/vendors/nearby', headers: auth_headers
        expect(response).to have_http_status(:ok)
        body  = JSON.parse(response.body)
        names = body.dig('data', 'vendors').map { |v| v['name'] }
        expect(names).to include('Pune Studio', 'Mumbai Studio')
        expect(body.dig('meta', 'engine')).to eq('global')
      end

      it 'ignores lat/lng/radius when supplied and still returns globally' do
        get '/api/v1/vendors/nearby',
            params: { latitude: 18.5204, longitude: 73.8567, radius: 1 },
            headers: auth_headers
        expect(response).to have_http_status(:ok)
        names = JSON.parse(response.body).dig('data', 'vendors').map { |v| v['name'] }
        expect(names).to include('Pune Studio', 'Mumbai Studio')
      end

      it 'returns distance_km as null but keeps the key in the payload' do
        get '/api/v1/vendors/nearby', headers: auth_headers
        vendor = JSON.parse(response.body).dig('data', 'vendors').first
        expect(vendor).to have_key('distance_m')
        expect(vendor).to have_key('distance_km')
        expect(vendor['distance_km']).to be_nil
      end

      it 'still respects min_rating' do
        get '/api/v1/vendors/nearby',
            params: { min_rating: 4.5 },
            headers: auth_headers
        names = JSON.parse(response.body).dig('data', 'vendors').map { |v| v['name'] }
        expect(names).to eq(['Mumbai Studio'])
      end

      it 'honors category filter and pagination together' do
        create(:decorator, name: 'Wedding Studio A', category: 'wedding',
                           rating_avg: 4.8, review_count: 50, active: true)
        create(:decorator, name: 'Wedding Studio B', category: 'wedding',
                           rating_avg: 4.6, review_count: 40, active: true)
        create(:decorator, name: 'Wedding Studio C', category: 'wedding',
                           rating_avg: 4.4, review_count: 30, active: true)
        create(:decorator, name: 'Birthday Studio',  category: 'birthday',
                           rating_avg: 5.0, review_count: 99, active: true)

        get '/api/v1/vendors/nearby',
            params: { category: 'wedding', per_page: 2, page: 1 },
            headers: auth_headers

        expect(response).to have_http_status(:ok)
        body  = JSON.parse(response.body)
        names = body.dig('data', 'vendors').map { |v| v['name'] }
        expect(names).to eq(['Wedding Studio A', 'Wedding Studio B']) # rating desc
        expect(names).not_to include('Birthday Studio', 'Pune Studio', 'Mumbai Studio')
        expect(body['meta']).to include('page' => 1, 'per_page' => 2, 'total' => 3, 'total_pages' => 2)

        get '/api/v1/vendors/nearby',
            params: { category: 'wedding', per_page: 2, page: 2 },
            headers: auth_headers
        page2 = JSON.parse(response.body).dig('data', 'vendors').map { |v| v['name'] }
        expect(page2).to eq(['Wedding Studio C'])
      end
    end
  end

  describe 'GET /api/v1/decorators' do
    context 'when flag is ON' do
      before { stub_flag(true) }

      it 'filters by city when supplied' do
        get '/api/v1/decorators', params: { city: 'Pune' }, headers: auth_headers
        names = JSON.parse(response.body).dig('data', 'decorators').map { |d| d['name'] }
        expect(names).to include('Pune Studio')
        expect(names).not_to include('Mumbai Studio')
      end
    end

    context 'when flag is OFF' do
      before { stub_flag(false) }

      it 'ignores the city filter and returns decorators globally' do
        get '/api/v1/decorators', params: { city: 'Pune' }, headers: auth_headers
        names = JSON.parse(response.body).dig('data', 'decorators').map { |d| d['name'] }
        expect(names).to include('Pune Studio', 'Mumbai Studio')
      end
    end
  end

  describe 'GET /api/v1/home/feed' do
    context 'when flag is ON' do
      before { stub_flag(true) }

      it 'scopes nearby_vendors by city' do
        get '/api/v1/home/feed', params: { city: 'Pune' }, headers: auth_headers
        names = JSON.parse(response.body).dig('data', 'nearby_vendors').map { |d| d['name'] }
        expect(names).to include('Pune Studio')
        expect(names).not_to include('Mumbai Studio')
      end
    end

    context 'when flag is OFF' do
      before { stub_flag(false) }

      it 'returns nearby_vendors globally regardless of city' do
        get '/api/v1/home/feed', params: { city: 'Pune' }, headers: auth_headers
        names = JSON.parse(response.body).dig('data', 'nearby_vendors').map { |d| d['name'] }
        expect(names).to include('Pune Studio', 'Mumbai Studio')
      end
    end
  end
end
