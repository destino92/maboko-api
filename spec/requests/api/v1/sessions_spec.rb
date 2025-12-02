# spec/requests/api/v1/sessions_spec.rb
require 'swagger_helper'

RSpec.describe 'Sessions API', type: :request, openapi_spec: 'v1/openapi.yaml' do
  let(:user) { User.create!(
    email_address: 'test@example.com',
    password: 'password123',
    password_confirmation: 'password123',
    first_name: 'John',
    last_name: 'Doe',
    phone_number: '+1234567890'
  )}

  path '/api/v1/session' do
    post 'Login' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email_address: { type: :string },
          password: { type: :string }
        },
        required: ['email_address', 'password']
      }

      response '201', 'logged in successfully' do
        schema type: :object,
          properties: {
            token: { type: :string },
            user: { '$ref' => '#/components/schemas/User' }
          }

        let(:credentials) do
          {
            email_address: user.email_address,
            password: 'password123'
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('token')
          expect(data).to have_key('user')
        end
      end

      response '401', 'invalid credentials' do
        let(:credentials) do
          {
            email_address: user.email_address,
            password: 'wrong_password'
          }
        end

        run_test!
      end
    end

    delete 'Logout' do
      tags 'Authentication'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      let(:session) { user.sessions.create! }
      let(:Authorization) { "Bearer #{session.token}" }

      response '200', 'logged out successfully' do
        run_test!
      end
    end
  end
end