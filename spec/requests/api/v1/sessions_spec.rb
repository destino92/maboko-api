# spec/requests/api/v1/sessions_spec.rb
require 'swagger_helper'

RSpec.describe 'Sessions API', type: :request do
  # Create test user before tests run
  let!(:user) do
    User.create!(
      email_address: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      first_name: 'John',
      last_name: 'Doe',
      phone_number: '+1234567890'
    )
  end

  path '/api/v1/session' do
    
    # ========================================================================
    # POST /api/v1/session - Login
    # ========================================================================
    
    post 'Login' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      description 'Authenticate user and receive session token'

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email_address: { 
            type: :string, 
            format: :email,
            description: 'User email address',
            example: 'test@example.com'
          },
          password: { 
            type: :string, 
            format: :password,
            description: 'User password',
            example: 'password123'
          }
        },
        required: ['email_address', 'password']
      }

      # Successful login
      response '201', 'logged in successfully' do
        schema type: :object,
          properties: {
            message: { type: :string, example: 'Logged in successfully' },
            token: { type: :string, example: 'abc123xyz' },
            user: { '$ref' => '#/components/schemas/User' }
          },
          required: ['token', 'user']

        let(:credentials) do
          {
            email_address: 'test@example.com',
            password: 'password123'
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('token')
          expect(data).to have_key('user')
          expect(data['user']['email_address']).to eq('test@example.com')
        end
      end

      # Invalid credentials
      response '401', 'invalid credentials' do
        schema '$ref' => '#/components/schemas/Error'

        let(:credentials) do
          {
            email_address: 'test@example.com',
            password: 'wrong_password'
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('error')
        end
      end

      # Missing parameters
      response '401', 'missing credentials' do
        let(:credentials) { {} }
        run_test!
      end
    end
    
    # ========================================================================
    # DELETE /api/v1/session - Logout
    # ========================================================================
    
    delete 'Logout' do
      tags 'Authentication'
      produces 'application/json'
      security [{ bearer_auth: [] }]
      description 'Destroy current session (logout)'

      let!(:session) { user.sessions.create! }
      let(:Authorization) { "Bearer #{session.token}" }

      # Successful logout
      response '200', 'logged out successfully' do
        schema type: :object,
          properties: {
            message: { type: :string, example: 'Logged out successfully' }
          }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('Logged out successfully')
          
          # Verify session was destroyed
          expect(Session.find_by(id: session.id)).to be_nil
        end
      end

      # Invalid or missing token
      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end
    end
  end
end