# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Designs API', type: :request do
  let!(:category)  { create(:category) }
  let!(:decorator) { create(:decorator) }
  let!(:design)    { create(:design, category: category, decorator: decorator) }

  path '/api/v1/designs' do
    parameter name: :slug,     in: :query, type: :string, required: false, description: 'Filter by category slug'
    parameter name: :q,        in: :query, type: :string, required: false, description: 'Search term'
    parameter name: :sort,     in: :query, type: :string, required: false, enum: %w[popular price_asc price_desc rating]
    parameter name: :page,     in: :query, type: :integer, required: false
    parameter name: :per_page, in: :query, type: :integer, required: false

    get 'List designs' do
      tags 'Catalogue'
      produces 'application/json'

      response '200', 'designs returned' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: {
                     designs: { type: :array, items: { '$ref' => '#/components/schemas/design_summary' } }
                   }
                 },
                 meta: { '$ref' => '#/components/schemas/pagination_meta' }
               }

        let(:slug) { nil }
        let(:q) { nil }
        let(:sort) { nil }
        let(:page) { nil }
        let(:per_page) { nil }

        run_test!
      end
    end
  end

  path '/api/v1/designs/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    get 'Get design details' do
      tags 'Catalogue'
      produces 'application/json'

      response '200', 'design details' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: { design: { '$ref' => '#/components/schemas/design' } }
                 }
               }

        let(:id) { design.id }

        run_test!
      end

      response '404', 'design not found' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:id) { 9_999_999 }

        run_test!
      end
    end
  end
end
