# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'DecorMySpace API',
        version: 'v1',
        description: 'Backend API for the DecorMySpace Flutter application',
        contact: {
          name: 'API Support'
        }
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        },
        {
          url: 'https://{productionHost}',
          description: 'Production server',
          variables: {
            productionHost: {
              default: 'api.decormyspace.com'
            }
          }
        }
      ],
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT',
            description: 'JWT access token obtained from login or register'
          }
        },
        schemas: {
          user: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              full_name: { type: :string, example: 'Jane Doe' },
              email: { type: :string, format: :email, example: 'jane@example.com' },
              phone: { type: :string, example: '+15550001111' },
              account_type: { type: :string, enum: %w[customer vendor], example: 'customer' },
              created_at: { type: :string, format: :'date-time', example: '2026-05-19T12:00:00Z' }
            },
            required: %w[id full_name email phone account_type created_at]
          },
          tokens: {
            type: :object,
            properties: {
              access_token: { type: :string, description: 'JWT access token (24h expiry)' },
              refresh_token: { type: :string, description: 'JWT refresh token (30d expiry)' },
              expires_in: { type: :integer, description: 'Access token TTL in seconds', example: 86400 }
            },
            required: %w[access_token refresh_token expires_in]
          },
          registration_request: {
            type: :object,
            properties: {
              user: {
                type: :object,
                properties: {
                  full_name: { type: :string, example: 'Jane Doe', minLength: 2 },
                  email: { type: :string, format: :email, example: 'jane@example.com' },
                  phone: { type: :string, example: '+15550001111' },
                  password: { type: :string, minLength: 8, example: 'securepass123' },
                  account_type: { type: :string, enum: %w[customer vendor], example: 'customer' },
                  accepted_terms: { type: :boolean, example: true }
                },
                required: %w[full_name email phone password account_type accepted_terms]
              }
            },
            required: %w[user]
          },
          login_request: {
            type: :object,
            properties: {
              session: {
                type: :object,
                properties: {
                  email: { type: :string, format: :email, example: 'jane@example.com' },
                  password: { type: :string, example: 'securepass123' }
                },
                required: %w[email password]
              }
            },
            required: %w[session]
          },
          success_response: {
            type: :object,
            properties: {
              success: { type: :boolean, example: true },
              message: { type: :string },
              data: { type: :object }
            }
          },
          error_response: {
            type: :object,
            properties: {
              success: { type: :boolean, example: false },
              error: { type: :string },
              errors: { type: :array, items: { type: :string } }
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
