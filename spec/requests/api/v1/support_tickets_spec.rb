# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Support Tickets API', type: :request do
  let(:user)         { create(:user) }
  let(:access_token) { JwtService.generate_tokens(user)[:access_token] }

  path '/api/v1/support_tickets' do
    post 'Submit a support ticket' do
      tags 'Support'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :params, in: :body, schema: { '$ref' => '#/components/schemas/support_ticket_request' }

      response '201', 'ticket created' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 message: { type: :string, example: 'Support ticket submitted' },
                 data: {
                   type: :object,
                   properties: { support_ticket: { '$ref' => '#/components/schemas/support_ticket' } }
                 }
               }

        let(:Authorization) { "Bearer #{access_token}" }
        let(:params) do
          { support_ticket: { category: 'Booking', subject: 'Cannot cancel my booking',
                              message: 'I tried to cancel but got an error.' } }
        end

        run_test!
      end

      response '422', 'validation errors' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{access_token}" }
        let(:params) { { support_ticket: { category: '', subject: '', message: '' } } }

        run_test!
      end

      response '401', 'missing token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { '' }
        let(:params) { { support_ticket: {} } }

        run_test!
      end
    end
  end
end
