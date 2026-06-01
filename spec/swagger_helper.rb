# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s

  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'DecorMySpace API',
        version: 'v1',
        description: 'Backend API for the DecorMySpace Flutter application',
        contact: { name: 'API Support' }
      },
      paths: {},
      servers: [
        { url: 'http://localhost:3000', description: 'Development server' },
        { url: 'https://{productionHost}', description: 'Production server',
          variables: { productionHost: { default: 'api.decormyspace.com' } } }
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
          # ---------- Generic envelopes ----------
          success_response: {
            type: :object,
            properties: {
              success: { type: :boolean, example: true },
              message: { type: :string },
              data:    { type: :object }
            }
          },
          error_response: {
            type: :object,
            properties: {
              success: { type: :boolean, example: false },
              error:   { type: :string,  example: 'Validation failed' },
              errors:  { type: :array, items: { type: :string } }
            }
          },
          pagination_meta: {
            type: :object,
            properties: {
              page:        { type: :integer, example: 1 },
              per_page:    { type: :integer, example: 20 },
              total:       { type: :integer, example: 42 },
              total_pages: { type: :integer, example: 3 }
            }
          },

          # ---------- Auth / user ----------
          user: {
            type: :object,
            properties: {
              id:           { type: :integer, example: 1 },
              full_name:    { type: :string,  example: 'Jane Doe' },
              email:        { type: :string, format: :email, example: 'jane@example.com' },
              phone:        { type: :string, example: '+15550001111' },
              account_type: { type: :string, enum: %w[customer vendor], example: 'customer' },
              username:     { type: :string, nullable: true, example: 'jane_d' },
              city:         { type: :string, nullable: true, example: 'Pune' },
              bio:          { type: :string, nullable: true },
              avatar_url:   { type: :string, nullable: true, example: 'https://i.pravatar.cc/200' },
              email_verified: { type: :boolean, example: false },
              phone_verified: { type: :boolean, example: false },
              created_at:   { type: :string, format: :'date-time', example: '2026-05-19T12:00:00Z' }
            },
            required: %w[id full_name email phone account_type created_at]
          },
          tokens: {
            type: :object,
            properties: {
              access_token:  { type: :string, description: 'JWT access token (24h expiry)' },
              refresh_token: { type: :string, description: 'JWT refresh token (30d expiry)' },
              expires_in:    { type: :integer, description: 'Access token TTL in seconds', example: 86400 }
            },
            required: %w[access_token refresh_token expires_in]
          },
          registration_request: {
            type: :object,
            properties: {
              user: {
                type: :object,
                properties: {
                  full_name:      { type: :string, example: 'Jane Doe', minLength: 2 },
                  email:          { type: :string, format: :email, example: 'jane@example.com' },
                  phone:          { type: :string, example: '+15550001111' },
                  password:       { type: :string, minLength: 8, example: 'securepass123' },
                  account_type:   { type: :string, enum: %w[customer vendor], example: 'customer' },
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
                  email:    { type: :string, format: :email, example: 'jane@example.com' },
                  password: { type: :string, example: 'securepass123' }
                },
                required: %w[email password]
              }
            },
            required: %w[session]
          },
          profile_update_request: {
            type: :object,
            properties: {
              user: {
                type: :object,
                properties: {
                  full_name:  { type: :string },
                  username:   { type: :string },
                  city:       { type: :string },
                  bio:        { type: :string },
                  avatar_url: { type: :string }
                }
              }
            },
            required: %w[user]
          },
          change_password_request: {
            type: :object,
            properties: {
              password: {
                type: :object,
                properties: {
                  current_password:          { type: :string, example: 'oldpassword123' },
                  new_password:              { type: :string, example: 'newpassword123' },
                  new_password_confirmation: { type: :string, example: 'newpassword123' }
                },
                required: %w[current_password new_password new_password_confirmation]
              }
            },
            required: %w[password]
          },
          request_email_change_request: {
            type: :object,
            properties: {
              email: {
                type: :object,
                properties: { new_email: { type: :string, format: :email, example: 'new@example.com' } },
                required: %w[new_email]
              }
            },
            required: %w[email]
          },
          confirm_email_change_request: {
            type: :object,
            properties: {
              code:      { type: :string, example: '123456' },
              new_email: { type: :string, format: :email, example: 'new@example.com' }
            },
            required: %w[code new_email]
          },
          request_phone_change_request: {
            type: :object,
            properties: {
              phone: {
                type: :object,
                properties: { new_phone: { type: :string, example: '+15550009999' } },
                required: %w[new_phone]
              }
            },
            required: %w[phone]
          },
          confirm_phone_change_request: {
            type: :object,
            properties: {
              code:      { type: :string, example: '123456' },
              new_phone: { type: :string, example: '+15550009999' }
            },
            required: %w[code new_phone]
          },

          # ---------- Catalogue ----------
          category: {
            type: :object,
            properties: {
              id:             { type: :integer, example: 1 },
              slug:           { type: :string, example: 'wedding' },
              title:          { type: :string, example: 'Wedding' },
              icon_key:       { type: :string, nullable: true, example: 'celebration' },
              tint_hex:       { type: :string, nullable: true, example: '#FCE4EC' },
              icon_color_hex: { type: :string, nullable: true, example: '#C2185B' },
              cover_url:      { type: :string, nullable: true },
              design_count:   { type: :integer, example: 12 },
              position:       { type: :integer, example: 1 }
            },
            required: %w[id slug title]
          },
          decorator: {
            type: :object,
            properties: {
              id:                  { type: :integer, example: 7 },
              name:                { type: :string, example: 'Bloom Decor Studio' },
              specialty:           { type: :string, nullable: true, example: 'Wedding specialist' },
              tagline:             { type: :string, nullable: true },
              rating_avg:          { type: :number, format: :float, example: 4.8 },
              review_count:        { type: :integer, example: 124 },
              avatar_url:          { type: :string, nullable: true },
              hourly_rate_rupees:  { type: :number, format: :float, example: 2500.0 },
              area:                { type: :string, nullable: true, example: 'Koregaon Park' },
              city:                { type: :string, nullable: true, example: 'Pune' },
              phone:               { type: :string, nullable: true },
              latitude:            { type: :number, nullable: true },
              longitude:           { type: :number, nullable: true }
            },
            required: %w[id name rating_avg review_count]
          },
          decorator_detail: {
            allOf: [
              { '$ref' => '#/components/schemas/decorator' },
              {
                type: :object,
                properties: {
                  bio:     { type: :string, nullable: true },
                  designs: { type: :array, items: { '$ref' => '#/components/schemas/design_summary' } }
                }
              }
            ]
          },
          design_summary: {
            type: :object,
            properties: {
              id:             { type: :integer, example: 42 },
              title:          { type: :string, example: 'Royal Mandap Floral Setup' },
              subtitle:       { type: :string, nullable: true },
              price_rupees:   { type: :integer, example: 45_000 },
              currency:       { type: :string, example: 'INR' },
              rating_avg:     { type: :number, format: :float, example: 4.9 },
              review_count:   { type: :integer, example: 56 },
              hero_image_url: { type: :string, nullable: true },
              available:      { type: :boolean, example: true },
              featured:       { type: :boolean, example: true },
              trending:       { type: :boolean, example: false },
              vendor_name:    { type: :string, nullable: true, example: 'Bloom Decor Studio' },
              category_slug:  { type: :string, nullable: true, example: 'wedding' }
            },
            required: %w[id title price_rupees currency available]
          },
          design: {
            allOf: [
              { '$ref' => '#/components/schemas/design_summary' },
              {
                type: :object,
                properties: {
                  description: { type: :string, nullable: true },
                  gallery:     { type: :array, items: { type: :string } },
                  inclusions:  {
                    type: :array,
                    items: {
                      type: :object,
                      properties: {
                        label:    { type: :string, example: 'Floral mandap' },
                        icon_key: { type: :string, nullable: true, example: 'local_florist' }
                      }
                    }
                  },
                  decorator: { '$ref' => '#/components/schemas/decorator' },
                  category:  { '$ref' => '#/components/schemas/category' }
                }
              }
            ]
          },
          add_on: {
            type: :object,
            properties: {
              id:           { type: :integer, example: 1 },
              key:          { type: :string,  example: 'photography' },
              label:        { type: :string,  example: 'Photography Package' },
              description:  { type: :string, nullable: true },
              price_rupees: { type: :integer, example: 15_000 }
            },
            required: %w[id key label price_rupees]
          },

          # ---------- Bookings ----------
          booking: {
            type: :object,
            properties: {
              id:                  { type: :integer, example: 101 },
              booking_reference:   { type: :string, example: 'DMS-AB12CD34' },
              status:              { type: :string, enum: %w[upcoming completed cancelled] },
              event_type:          { type: :string, example: 'Wedding' },
              event_date:          { type: :string, format: :date, example: '2026-08-21' },
              time_slot:           { type: :string, example: '18:00-22:00' },
              expected_guests:     { type: :integer, example: 250 },
              venue_name:          { type: :string, example: 'Taj Banquet Hall' },
              venue_address_line1: { type: :string, example: 'MG Road' },
              venue_address_line2: { type: :string, nullable: true },
              contact_full_name:   { type: :string, example: 'Riya Shah' },
              contact_phone:       { type: :string, example: '+919812345678' },
              contact_email:       { type: :string, format: :email },
              special_instructions:{ type: :string, nullable: true },
              subtotal_rupees:     { type: :integer, example: 60_000 },
              gst_rupees:          { type: :integer, example: 10_800 },
              total_rupees:        { type: :integer, example: 70_800 },
              advance_paid_rupees: { type: :integer, example: 21_240 },
              balance_rupees:      { type: :integer, example: 49_560 },
              payment_method:      { type: :string, enum: %w[card upi netbanking] },
              payment_status:      { type: :string, enum: %w[pending paid refunded] },
              placed_on:           { type: :string, format: :'date-time' },
              cancelled_at:        { type: :string, format: :'date-time', nullable: true },
              cancellation_reason: { type: :string, nullable: true },
              design:    { '$ref' => '#/components/schemas/design_summary' },
              decorator: { '$ref' => '#/components/schemas/decorator' },
              add_ons:   { type: :array, items: { '$ref' => '#/components/schemas/add_on' } }
            },
            required: %w[id booking_reference status event_type event_date total_rupees]
          },
          booking_request: {
            type: :object,
            properties: {
              booking: {
                type: :object,
                properties: {
                  design_id:           { type: :integer, example: 42 },
                  event_type:          { type: :string, example: 'Wedding' },
                  event_date:          { type: :string, format: :date, example: '2026-08-21' },
                  time_slot:           { type: :string, example: '18:00-22:00' },
                  expected_guests:     { type: :integer, example: 250 },
                  venue_name:          { type: :string, example: 'Taj Banquet Hall' },
                  venue_address_line1: { type: :string, example: 'MG Road' },
                  venue_address_line2: { type: :string, example: 'Pune' },
                  contact_full_name:   { type: :string, example: 'Riya Shah' },
                  contact_phone:       { type: :string, example: '+919812345678' },
                  contact_email:       { type: :string, format: :email, example: 'riya@example.com' },
                  special_instructions:{ type: :string, example: 'Use white florals only' },
                  payment_method:      { type: :string, enum: %w[card upi netbanking], example: 'upi' },
                  add_on_ids:          { type: :array, items: { type: :integer }, example: [1, 3] }
                },
                required: %w[design_id event_type event_date time_slot venue_name venue_address_line1
                             contact_full_name contact_phone contact_email payment_method]
              }
            },
            required: %w[booking]
          },
          cancel_booking_request: {
            type: :object,
            properties: { reason: { type: :string, example: 'Plans changed' } }
          },

          # ---------- Reviews ----------
          review_object: {
            type: :object,
            properties: {
              id:              { type: :integer, example: 11 },
              rating:          { type: :integer, minimum: 1, maximum: 5, example: 5 },
              comment:         { type: :string, nullable: true },
              tags:            { type: :array, items: { type: :string }, example: %w[on-time professional] },
              would_recommend: { type: :boolean, example: true },
              created_at:      { type: :string, format: :'date-time' }
            },
            required: %w[id rating]
          },
          review_request: {
            type: :object,
            properties: {
              review: {
                type: :object,
                properties: {
                  rating:          { type: :integer, minimum: 1, maximum: 5, example: 5 },
                  comment:         { type: :string, example: 'Beautiful work, very professional' },
                  tags:            { type: :array, items: { type: :string }, example: %w[on-time creative] },
                  would_recommend: { type: :boolean, example: true }
                },
                required: %w[rating]
              }
            },
            required: %w[review]
          },

          # ---------- Saved designs ----------
          saved_design: {
            type: :object,
            properties: {
              id:         { type: :integer, example: 12 },
              created_at: { type: :string, format: :'date-time' },
              design:     { '$ref' => '#/components/schemas/design_summary' }
            },
            required: %w[id design]
          },
          saved_design_request: {
            type: :object,
            properties: { design_id: { type: :integer, example: 42 } },
            required: %w[design_id]
          },

          # ---------- Addresses ----------
          address: {
            type: :object,
            properties: {
              id:             { type: :integer, example: 5 },
              label:          { type: :string, example: 'Home' },
              recipient_name: { type: :string, example: 'Riya Shah' },
              line1:          { type: :string, example: '12 MG Road' },
              line2:          { type: :string, nullable: true },
              city:           { type: :string, nullable: true, example: 'Pune' },
              state:          { type: :string, nullable: true, example: 'MH' },
              postal_code:    { type: :string, nullable: true, example: '411001' },
              country:        { type: :string, example: 'IN' },
              phone:          { type: :string, example: '+919812345678' },
              is_default:     { type: :boolean, example: true }
            },
            required: %w[id label recipient_name line1 country phone]
          },
          address_request: {
            type: :object,
            properties: {
              address: {
                type: :object,
                properties: {
                  label:          { type: :string, example: 'Home' },
                  recipient_name: { type: :string, example: 'Riya Shah' },
                  line1:          { type: :string, example: '12 MG Road' },
                  line2:          { type: :string, example: 'Near MG Metro' },
                  city:           { type: :string, example: 'Pune' },
                  state:          { type: :string, example: 'MH' },
                  postal_code:    { type: :string, example: '411001' },
                  country:        { type: :string, example: 'IN' },
                  phone:          { type: :string, example: '+919812345678' },
                  is_default:     { type: :boolean, example: false }
                },
                required: %w[label recipient_name line1 country phone]
              }
            },
            required: %w[address]
          },

          # ---------- Payment methods ----------
          payment_method: {
            type: :object,
            properties: {
              id:         { type: :integer, example: 8 },
              kind:       { type: :string, enum: %w[card upi wallet], example: 'card' },
              title:      { type: :string, example: 'Visa ending 4242' },
              subtitle:   { type: :string, nullable: true, example: 'Personal' },
              last4:      { type: :string, nullable: true, example: '4242' },
              is_default: { type: :boolean, example: true },
              expires_on: { type: :string, format: :date, nullable: true }
            },
            required: %w[id kind title is_default]
          },
          payment_method_request: {
            type: :object,
            properties: {
              payment_method: {
                type: :object,
                properties: {
                  kind:           { type: :string, enum: %w[card upi wallet] },
                  title:          { type: :string, example: 'Visa ending 4242' },
                  subtitle:       { type: :string, example: 'Personal' },
                  last4:          { type: :string, example: '4242' },
                  provider_token: { type: :string, example: 'tok_xxx' },
                  expires_on:     { type: :string, format: :date, example: '2030-01-01' },
                  is_default:     { type: :boolean, example: false }
                },
                required: %w[kind title]
              }
            },
            required: %w[payment_method]
          },

          # ---------- Notifications ----------
          notification: {
            type: :object,
            properties: {
              id:         { type: :integer, example: 91 },
              title:      { type: :string, example: 'Booking confirmed' },
              body:       { type: :string, nullable: true },
              kind:       { type: :string, enum: %w[system booking promotion payment] },
              payload:    { type: :object, additionalProperties: true },
              unread:     { type: :boolean, example: true },
              created_at: { type: :string, format: :'date-time' }
            },
            required: %w[id title kind unread created_at]
          },

          # ---------- Preferences ----------
          user_preference: {
            type: :object,
            properties: {
              locale:            { type: :string, enum: %w[en ar hi], example: 'en' },
              currency:          { type: :string, enum: %w[INR USD EUR AED], example: 'INR' },
              dark_mode:         { type: :boolean, example: false },
              location_services: { type: :boolean, example: true },
              notify_bookings:   { type: :boolean, example: true },
              notify_promotions: { type: :boolean, example: true },
              notify_system:     { type: :boolean, example: true }
            }
          },
          preferences_request: {
            type: :object,
            properties: {
              preferences: { '$ref' => '#/components/schemas/user_preference' }
            },
            required: %w[preferences]
          },

          # ---------- Support ----------
          support_ticket: {
            type: :object,
            properties: {
              id:         { type: :integer, example: 3 },
              category:   { type: :string, example: 'Booking' },
              subject:    { type: :string, example: 'Cannot cancel my booking' },
              message:    { type: :string },
              status:     { type: :string, enum: %w[open in_progress resolved closed], example: 'open' },
              created_at: { type: :string, format: :'date-time' }
            },
            required: %w[id category subject status created_at]
          },
          support_ticket_request: {
            type: :object,
            properties: {
              support_ticket: {
                type: :object,
                properties: {
                  category: { type: :string, example: 'Booking' },
                  subject:  { type: :string, example: 'Cannot cancel my booking' },
                  message:  { type: :string, example: 'I tried to cancel but got an error.' }
                },
                required: %w[category subject message]
              }
            },
            required: %w[support_ticket]
          },
          user_location_request: {
            type: :object,
            properties: {
              latitude:   { type: :number, format: :float, example: 23.0225, minimum: -90,  maximum: 90 },
              longitude:  { type: :number, format: :float, example: 72.5714, minimum: -180, maximum: 180 },
              accuracy_m: { type: :number, format: :float, example: 12.5, nullable: true },
              source:     { type: :string, example: 'client', nullable: true }
            },
            required: %w[latitude longitude]
          },
          nearby_vendor: {
            type: :object,
            properties: {
              id:             { type: :integer, example: 42 },
              name:           { type: :string,  example: 'Bloom Decor Studio' },
              category:       { type: :string, nullable: true, example: 'wedding' },
              specialty:      { type: :string, nullable: true },
              rating_avg:     { type: :number, format: :float, example: 4.7 },
              review_count:   { type: :integer, example: 124 },
              open:           { type: :boolean, example: true },
              latitude:       { type: :number, format: :float, example: 23.02 },
              longitude:      { type: :number, format: :float, example: 72.57 },
              distance_m:     { type: :number, format: :float, example: 1240.5 },
              distance_km:    { type: :number, format: :float, example: 1.241 },
              distance_miles: { type: :number, format: :float, example: 0.771 },
              avatar_url:     { type: :string, nullable: true },
              city:           { type: :string, nullable: true },
              area:           { type: :string, nullable: true }
            },
            required: %w[id name rating_avg open distance_m]
          },
          nearby_meta: {
            allOf: [
              { '$ref' => '#/components/schemas/pagination_meta' },
              {
                type: :object,
                properties: {
                  radius_m: { type: :integer, example: 5000 },
                  engine:   { type: :string, enum: %w[postgis haversine], example: 'postgis' }
                }
              }
            ]
          }
        }
      }
    }
  }

  config.openapi_format = :yaml
end
