# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Bookings API', type: :request do
  let(:user)      { create(:user) }
  let(:other)     { create(:user) }
  let(:decorator) { create(:decorator) }
  let(:category)  { create(:category) }
  let(:design)    { create(:design, decorator: decorator, category: category, price_cents: 4_500_000) }
  let(:add_on)    { create(:add_on, price_cents: 1_500_000) }
  let(:access_token) { JwtService.generate_tokens(user)[:access_token] }

  path '/api/v1/bookings' do
    parameter name: :status,   in: :query, type: :string, required: false, enum: %w[upcoming completed cancelled]
    parameter name: :page,     in: :query, type: :integer, required: false
    parameter name: :per_page, in: :query, type: :integer, required: false

    get 'List current user bookings' do
      tags 'Bookings'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'bookings returned' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: {
                     bookings: { type: :array, items: { '$ref' => '#/components/schemas/booking' } }
                   }
                 },
                 meta: { '$ref' => '#/components/schemas/pagination_meta' }
               }

        before { create(:booking, user: user, design: design, decorator: decorator) }

        let(:Authorization) { "Bearer #{access_token}" }
        let(:status) { nil }
        let(:page) { nil }
        let(:per_page) { nil }

        run_test! do |response|
          expect(JSON.parse(response.body)['data']['bookings'].size).to eq(1)
        end
      end

      response '401', 'missing token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { '' }
        let(:status) { nil }
        let(:page) { nil }
        let(:per_page) { nil }

        run_test!
      end
    end

    post 'Create a booking' do
      tags 'Bookings'
      description 'Creates a booking. Pricing (subtotal, 18% GST, 30% advance) is computed server-side.'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :params, in: :body, schema: { '$ref' => '#/components/schemas/booking_request' }

      response '201', 'booking created' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 message: { type: :string, example: 'Booking confirmed' },
                 data: {
                   type: :object,
                   properties: { booking: { '$ref' => '#/components/schemas/booking' } }
                 }
               }

        let(:Authorization) { "Bearer #{access_token}" }
        let(:params) do
          {
            booking: {
              design_id: design.id,
              event_type: 'Wedding',
              event_date: 30.days.from_now.to_date.iso8601,
              time_slot: '18:00-22:00',
              expected_guests: 200,
              venue_name: 'Taj Banquet Hall',
              venue_address_line1: 'MG Road',
              contact_full_name: 'Riya Shah',
              contact_phone: '+919812345678',
              contact_email: 'riya@example.com',
              payment_method: 'upi',
              add_on_ids: [add_on.id]
            }
          }
        end

        run_test! do |response|
          booking = JSON.parse(response.body)['data']['booking']
          expect(booking['booking_reference']).to start_with('DMS-')
          # 45000 + 15000 = 60000 subtotal; gst 18% = 10800; total 70800; advance 30% = 21240
          expect(booking['total_rupees']).to eq(70_800)
          expect(booking['advance_paid_rupees']).to eq(21_240)
        end
      end

      response '404', 'design not found' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{access_token}" }
        let(:params) do
          { booking: { design_id: 9_999_999, event_type: 'X', event_date: '2026-08-21',
                       time_slot: '18:00', venue_name: 'V', venue_address_line1: 'A',
                       contact_full_name: 'N', contact_phone: '+91981', contact_email: 'a@b.com',
                       payment_method: 'upi' } }
        end

        run_test!
      end

      response '422', 'validation errors' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{access_token}" }
        let(:params) do
          { booking: { design_id: design.id, event_type: 'Wedding',
                       event_date: 30.days.from_now.to_date.iso8601,
                       time_slot: '', venue_name: '', venue_address_line1: '',
                       contact_full_name: '', contact_phone: '', contact_email: 'not-an-email',
                       payment_method: 'upi' } }
        end

        run_test!
      end

      response '401', 'missing token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { '' }
        let(:params) { { booking: {} } }

        run_test!
      end
    end
  end

  path '/api/v1/bookings/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    get 'Get booking details' do
      tags 'Bookings'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'booking returned' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: { booking: { '$ref' => '#/components/schemas/booking' } }
                 }
               }

        let(:booking_record) { create(:booking, user: user, design: design, decorator: decorator) }
        let(:Authorization) { "Bearer #{access_token}" }
        let(:id) { booking_record.id }

        run_test!
      end

      response '404', 'booking not found or not owned' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:other_booking) { create(:booking, user: other, design: design, decorator: decorator) }
        let(:Authorization) { "Bearer #{access_token}" }
        let(:id) { other_booking.id }

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

  path '/api/v1/bookings/{id}/cancel' do
    parameter name: :id, in: :path, type: :integer, required: true

    patch 'Cancel a booking' do
      tags 'Bookings'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :params, in: :body, schema: { '$ref' => '#/components/schemas/cancel_booking_request' }

      response '200', 'booking cancelled' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 message: { type: :string, example: 'Booking cancelled' },
                 data: {
                   type: :object,
                   properties: { booking: { '$ref' => '#/components/schemas/booking' } }
                 }
               }

        let(:booking_record) { create(:booking, user: user, design: design, decorator: decorator) }
        let(:Authorization) { "Bearer #{access_token}" }
        let(:id) { booking_record.id }
        let(:params) { { reason: 'Plans changed' } }

        run_test! do |response|
          expect(JSON.parse(response.body)['data']['booking']['status']).to eq('cancelled')
        end
      end

      response '422', 'already cancelled' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:booking_record) { create(:booking, user: user, design: design, decorator: decorator, status: :cancelled) }
        let(:Authorization) { "Bearer #{access_token}" }
        let(:id) { booking_record.id }
        let(:params) { { reason: 'whatever' } }

        run_test!
      end

      response '404', 'booking not found' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{access_token}" }
        let(:id) { 9_999_999 }
        let(:params) { { reason: 'nope' } }

        run_test!
      end

      response '401', 'missing token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { '' }
        let(:id) { 1 }
        let(:params) { {} }

        run_test!
      end
    end
  end
end
