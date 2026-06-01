# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Reviews API', type: :request do
  let(:user)      { create(:user) }
  let(:decorator) { create(:decorator) }
  let(:category)  { create(:category) }
  let(:design)    { create(:design, decorator: decorator, category: category) }
  let(:access_token) { JwtService.generate_tokens(user)[:access_token] }

  path '/api/v1/bookings/{booking_id}/review' do
    parameter name: :booking_id, in: :path, type: :integer, required: true

    post 'Submit a review for a completed booking' do
      tags 'Reviews'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :params, in: :body, schema: { '$ref' => '#/components/schemas/review_request' }

      response '201', 'review created' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 message: { type: :string, example: 'Thanks for your review' },
                 data: {
                   type: :object,
                   properties: { review: { '$ref' => '#/components/schemas/review_object' } }
                 }
               }

        let(:booking) do
          create(:booking, user: user, design: design, decorator: decorator,
                           status: :completed, event_date: 5.days.ago)
        end
        let(:Authorization) { "Bearer #{access_token}" }
        let(:booking_id) { booking.id }
        let(:params) do
          { review: { rating: 5, comment: 'Excellent setup',
                      tags: %w[on-time creative], would_recommend: true } }
        end

        run_test!
      end

      response '422', 'cannot review an upcoming booking' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:booking) { create(:booking, user: user, design: design, decorator: decorator) }
        let(:Authorization) { "Bearer #{access_token}" }
        let(:booking_id) { booking.id }
        let(:params) { { review: { rating: 5 } } }

        run_test!
      end

      response '404', 'booking not owned by user' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:other_user) { create(:user) }
        let(:booking)    { create(:booking, user: other_user, design: design, decorator: decorator) }
        let(:Authorization) { "Bearer #{access_token}" }
        let(:booking_id) { booking.id }
        let(:params) { { review: { rating: 5 } } }

        run_test!
      end

      response '401', 'missing token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { '' }
        let(:booking_id) { 1 }
        let(:params) { { review: { rating: 5 } } }

        run_test!
      end
    end
  end
end
