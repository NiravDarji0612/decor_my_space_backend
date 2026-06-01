# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Notifications API', type: :request do
  let(:user)         { create(:user) }
  let(:access_token) { JwtService.generate_tokens(user)[:access_token] }

  path '/api/v1/notifications' do
    parameter name: :unread,   in: :query, type: :boolean, required: false
    parameter name: :page,     in: :query, type: :integer, required: false
    parameter name: :per_page, in: :query, type: :integer, required: false

    get 'List notifications' do
      tags 'Notifications'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'notifications returned' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: {
                     notifications: { type: :array, items: { '$ref' => '#/components/schemas/notification' } },
                     unread_count:  { type: :integer, example: 1 }
                   }
                 },
                 meta: { '$ref' => '#/components/schemas/pagination_meta' }
               }

        before { user.notifications.create!(title: 'Hello', kind: :system) }

        let(:Authorization) { "Bearer #{access_token}" }
        let(:unread)        { nil }
        let(:page)          { nil }
        let(:per_page)      { nil }

        run_test!
      end

      response '401', 'missing token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { '' }
        let(:unread)        { nil }
        let(:page)          { nil }
        let(:per_page)      { nil }

        run_test!
      end
    end
  end

  path '/api/v1/notifications/read_all' do
    patch 'Mark all notifications as read' do
      tags 'Notifications'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'marked as read' do
        schema '$ref' => '#/components/schemas/success_response'

        let(:Authorization) { "Bearer #{access_token}" }

        run_test!
      end

      response '401', 'missing token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { '' }

        run_test!
      end
    end
  end

  path '/api/v1/notifications/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    delete 'Dismiss a notification' do
      tags 'Notifications'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'dismissed' do
        schema '$ref' => '#/components/schemas/success_response'

        let(:n)             { user.notifications.create!(title: 'Hi', kind: :system) }
        let(:Authorization) { "Bearer #{access_token}" }
        let(:id)            { n.id }

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
end
