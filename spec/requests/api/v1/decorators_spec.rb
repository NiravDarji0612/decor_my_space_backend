# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Decorators API', type: :request do
  let!(:decorator) { create(:decorator) }

  path '/api/v1/decorators' do
    parameter name: :city,     in: :query, type: :string, required: false
    parameter name: :q,        in: :query, type: :string, required: false
    parameter name: :page,     in: :query, type: :integer, required: false
    parameter name: :per_page, in: :query, type: :integer, required: false

    get 'List decorators (vendors)' do
      tags 'Catalogue'
      produces 'application/json'

      response '200', 'decorators returned' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: {
                     decorators: { type: :array, items: { '$ref' => '#/components/schemas/decorator' } }
                   }
                 },
                 meta: { '$ref' => '#/components/schemas/pagination_meta' }
               }

        let(:city) { nil }
        let(:q) { nil }
        let(:page) { nil }
        let(:per_page) { nil }

        run_test!
      end
    end
  end

  path '/api/v1/decorators/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    get 'Get decorator details with design gallery' do
      tags 'Catalogue'
      produces 'application/json'

      response '200', 'decorator details' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: { decorator: { '$ref' => '#/components/schemas/decorator_detail' } }
                 }
               }

        let(:id) { decorator.id }

        run_test!
      end

      response '404', 'decorator not found' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:id) { 9_999_999 }

        run_test!
      end
    end
  end
end
