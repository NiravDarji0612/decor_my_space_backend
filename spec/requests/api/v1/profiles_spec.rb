# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Profile API', type: :request do
  let!(:user) { create(:user, :vendor, email: 'profile@example.com') }

  path '/api/v1/profile' do
    get 'Get current user profile' do
      tags 'Profile'
      description 'Returns the authenticated user\'s profile information. Requires a valid JWT access token.'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'profile retrieved' do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 data: {
                   type: :object,
                   properties: {
                     user: { '$ref' => '#/components/schemas/user' }
                   }
                 }
               }

        let(:Authorization) do
          token = JwtService.encode({ user_id: user.id })
          "Bearer #{token}"
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['success']).to be true
          expect(json['data']['user']['email']).to eq('profile@example.com')
          expect(json['data']['user']['account_type']).to eq('vendor')
        end
      end

      response '401', 'missing token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { '' }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['error']).to eq('Missing authorization token')
        end
      end

      response '401', 'invalid token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { 'Bearer invalid.token.here' }

        run_test!
      end
    end

    patch 'Update profile' do
      tags 'Profile'
      description 'Updates editable profile fields for the authenticated user.'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :params, in: :body, schema: { '$ref' => '#/components/schemas/profile_update_request' }

      response '200', 'profile updated' do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 message: { type: :string, example: 'Profile updated' },
                 data: {
                   type: :object,
                   properties: { user: { '$ref' => '#/components/schemas/user' } }
                 }
               }

        let(:Authorization) { "Bearer #{JwtService.generate_tokens(user)[:access_token]}" }
        let(:params) { { user: { full_name: 'Updated Name', city: 'Mumbai' } } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']['user']['full_name']).to eq('Updated Name')
          expect(json['data']['user']['city']).to eq('Mumbai')
        end
      end

      response '401', 'missing token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { '' }
        let(:params) { { user: { full_name: 'X' } } }

        run_test!
      end

      response '422', 'invalid username' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{JwtService.generate_tokens(user)[:access_token]}" }
        let(:params) { { user: { username: 'a' } } }  # too short

        run_test!
      end
    end
  end

  path '/api/v1/account' do
    delete 'Delete (soft-delete) the current account' do
      tags 'Profile'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'account deleted' do
        schema '$ref' => '#/components/schemas/success_response'

        let(:Authorization) { "Bearer #{JwtService.generate_tokens(user)[:access_token]}" }

        run_test!
      end

      response '401', 'missing token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { '' }

        run_test!
      end
    end
  end

  path '/api/v1/profile/password' do
    patch 'Change password' do
      tags 'Profile'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :params, in: :body, schema: { '$ref' => '#/components/schemas/change_password_request' }

      response '200', 'password changed' do
        schema '$ref' => '#/components/schemas/success_response'

        let(:Authorization) { "Bearer #{JwtService.generate_tokens(user)[:access_token]}" }
        let(:params) do
          { password: { current_password: 'password123',
                        new_password: 'newpassword456',
                        new_password_confirmation: 'newpassword456' } }
        end

        run_test!
      end

      response '422', 'current password incorrect' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{JwtService.generate_tokens(user)[:access_token]}" }
        let(:params) do
          { password: { current_password: 'wrong',
                        new_password: 'newpassword456',
                        new_password_confirmation: 'newpassword456' } }
        end

        run_test! do |response|
          expect(JSON.parse(response.body)['error']).to eq('Current password is incorrect')
        end
      end

      response '422', 'new password mismatch' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{JwtService.generate_tokens(user)[:access_token]}" }
        let(:params) do
          { password: { current_password: 'password123',
                        new_password: 'newpassword456',
                        new_password_confirmation: 'mismatch' } }
        end

        run_test!
      end

      response '401', 'missing token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { '' }
        let(:params) { { password: {} } }

        run_test!
      end
    end
  end

  path '/api/v1/profile/email/request' do
    post 'Request OTP to change email' do
      tags 'Profile'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :params, in: :body, schema: { '$ref' => '#/components/schemas/request_email_change_request' }

      response '200', 'otp issued' do
        schema '$ref' => '#/components/schemas/success_response'

        let(:Authorization) { "Bearer #{JwtService.generate_tokens(user)[:access_token]}" }
        let(:params) { { email: { new_email: 'newprofile@example.com' } } }

        run_test!
      end

      response '422', 'invalid email' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{JwtService.generate_tokens(user)[:access_token]}" }
        let(:params) { { email: { new_email: 'not-an-email' } } }

        run_test!
      end

      response '422', 'email already in use' do
        schema '$ref' => '#/components/schemas/error_response'

        before { create(:user, email: 'taken@example.com') }

        let(:Authorization) { "Bearer #{JwtService.generate_tokens(user)[:access_token]}" }
        let(:params) { { email: { new_email: 'taken@example.com' } } }

        run_test!
      end

      response '401', 'missing token' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { '' }
        let(:params) { { email: { new_email: 'a@b.com' } } }

        run_test!
      end
    end
  end

  path '/api/v1/profile/email/confirm' do
    post 'Confirm email change with OTP' do
      tags 'Profile'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :params, in: :body, schema: { '$ref' => '#/components/schemas/confirm_email_change_request' }

      response '200', 'email updated' do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 message: { type: :string, example: 'Email updated' },
                 data: {
                   type: :object,
                   properties: { user: { '$ref' => '#/components/schemas/user' } }
                 }
               }

        before do
          @captured_code = nil
          allow(OtpDeliveryJob).to receive(:perform_later) { |args| @captured_code = args[:code] }
          OtpService.issue(user: user, purpose: :email_change,
                           destination: 'newprofile@example.com', channel: :email)
        end

        let(:Authorization) { "Bearer #{JwtService.generate_tokens(user)[:access_token]}" }
        let(:params) { { code: @captured_code, new_email: 'newprofile@example.com' } }

        run_test! do |response|
          expect(JSON.parse(response.body)['data']['user']['email']).to eq('newprofile@example.com')
        end
      end

      response '422', 'invalid otp code' do
        schema '$ref' => '#/components/schemas/error_response'

        before do
          allow(OtpDeliveryJob).to receive(:perform_later)
          OtpService.issue(user: user, purpose: :email_change,
                           destination: 'newprofile@example.com', channel: :email)
        end

        let(:Authorization) { "Bearer #{JwtService.generate_tokens(user)[:access_token]}" }
        let(:params) { { code: '000000', new_email: 'newprofile@example.com' } }

        run_test!
      end
    end
  end

  path '/api/v1/profile/phone/request' do
    post 'Request OTP to change phone number' do
      tags 'Profile'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :params, in: :body, schema: { '$ref' => '#/components/schemas/request_phone_change_request' }

      response '200', 'otp issued' do
        schema '$ref' => '#/components/schemas/success_response'

        let(:Authorization) { "Bearer #{JwtService.generate_tokens(user)[:access_token]}" }
        let(:params) { { phone: { new_phone: '+15550009999' } } }

        run_test!
      end

      response '422', 'invalid phone' do
        schema '$ref' => '#/components/schemas/error_response'

        let(:Authorization) { "Bearer #{JwtService.generate_tokens(user)[:access_token]}" }
        let(:params) { { phone: { new_phone: '123' } } }

        run_test!
      end
    end
  end

  path '/api/v1/profile/phone/confirm' do
    post 'Confirm phone change with OTP' do
      tags 'Profile'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :params, in: :body, schema: { '$ref' => '#/components/schemas/confirm_phone_change_request' }

      response '200', 'phone updated' do
        schema type: :object,
               properties: {
                 success: { type: :boolean, example: true },
                 message: { type: :string, example: 'Phone updated' },
                 data: {
                   type: :object,
                   properties: { user: { '$ref' => '#/components/schemas/user' } }
                 }
               }

        before do
          @captured_code = nil
          allow(OtpDeliveryJob).to receive(:perform_later) { |args| @captured_code = args[:code] }
          OtpService.issue(user: user, purpose: :phone_change,
                           destination: '+15550009999', channel: :sms)
        end

        let(:Authorization) { "Bearer #{JwtService.generate_tokens(user)[:access_token]}" }
        let(:params) { { code: @captured_code, new_phone: '+15550009999' } }

        run_test!
      end

      response '422', 'invalid otp code' do
        schema '$ref' => '#/components/schemas/error_response'

        before do
          allow(OtpDeliveryJob).to receive(:perform_later)
          OtpService.issue(user: user, purpose: :phone_change,
                           destination: '+15550009999', channel: :sms)
        end

        let(:Authorization) { "Bearer #{JwtService.generate_tokens(user)[:access_token]}" }
        let(:params) { { code: '000000', new_phone: '+15550009999' } }

        run_test!
      end
    end
  end
end
