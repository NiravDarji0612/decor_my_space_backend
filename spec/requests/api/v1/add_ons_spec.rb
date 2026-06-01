# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'AddOns API', type: :request do
  let!(:add_on) { create(:add_on) }

  path '/api/v1/add_ons' do
    get 'List active booking add-ons' do
      tags 'Catalogue'
      produces 'application/json'

      response '200', 'add-ons returned' do
        schema type: :object,
               properties: {
                 success: { type: :boolean },
                 data: {
                   type: :object,
                   properties: {
                     add_ons: { type: :array, items: { '$ref' => '#/components/schemas/add_on' } }
                   }
                 }
               }

        run_test!
      end
    end
  end
end
