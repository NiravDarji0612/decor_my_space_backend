# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Categories API', type: :request do
  before do
    create(:category, slug: 'wedding',  title: 'Wedding',  position: 1)
    create(:category, slug: 'birthday', title: 'Birthday', position: 2)
  end

  path '/api/v1/categories' do
    get 'List active categories' do
      tags 'Catalogue'
      description 'Returns active categories ordered by position.'
      produces 'application/json'

      response '200', 'categories returned' do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 data: {
                   type: :object,
                   properties: {
                     categories: { type: :array, items: { '$ref' => '#/components/schemas/category' } }
                   }
                 }
               }

        run_test! do |response|
          slugs = JSON.parse(response.body).dig('data', 'categories').map { |c| c['slug'] }
          expect(slugs).to eq(%w[wedding birthday])
        end
      end
    end
  end

  path '/api/v1/categories/{slug}' do
    parameter name: :slug, in: :path, type: :string, required: true, example: 'wedding'

    get 'Get a category by slug' do
      tags 'Catalogue'
      produces 'application/json'

      response '200', 'category returned' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: { category: { '$ref' => '#/components/schemas/category' } }
                 }
               }

        let(:slug) { 'wedding' }

        run_test!
      end

      response '404', 'category not found' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:slug) { 'unknown' }

        run_test!
      end
    end
  end

  path '/api/v1/categories/{slug}/designs' do
    parameter name: :slug, in: :path, type: :string, required: true, example: 'wedding'
    parameter name: :sort,    in: :query, type: :string, required: false, enum: %w[popular price_asc price_desc rating]
    parameter name: :page,    in: :query, type: :integer, required: false
    parameter name: :per_page,in: :query, type: :integer, required: false

    get 'List designs in a category' do
      tags 'Catalogue'
      produces 'application/json'

      response '200', 'designs returned' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: {
                     category: { '$ref' => '#/components/schemas/category' },
                     designs:  { type: :array, items: { '$ref' => '#/components/schemas/design_summary' } }
                   }
                 },
                 meta: { '$ref' => '#/components/schemas/pagination_meta' }
               }

        let(:slug) { 'wedding' }
        let(:sort) { nil }
        let(:page) { nil }
        let(:per_page) { nil }

        run_test!
      end

      response '404', 'category not found' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:slug) { 'unknown' }
        let(:sort) { nil }
        let(:page) { nil }
        let(:per_page) { nil }

        run_test!
      end
    end
  end
end
