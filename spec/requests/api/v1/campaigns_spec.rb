# spec/requests/api/v1/campaigns_spec.rb
require 'swagger_helper'

RSpec.describe 'Campaigns API', type: :request do
  # Setup test data
  let!(:category) { Category.create!(name: 'Medical', slug: 'medical') }
  let!(:user) do
    User.create!(
      email_address: 'creator@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      first_name: 'Jane',
      last_name: 'Smith',
      phone_number: '+1987654321'
    )
  end
  let!(:session) { user.sessions.create! }
  let(:Authorization) { "Bearer #{session.token}" }

  path '/api/v1/campaigns' do
    
    # ========================================================================
    # GET /api/v1/campaigns - List Campaigns
    # ========================================================================
    
    get 'List campaigns' do
      tags 'Campaigns'
      produces 'application/json'
      description 'Retrieve list of campaigns with filtering, searching, and pagination'

      parameter name: :category_id, in: :query, type: :integer, required: false,
        description: 'Filter by category ID'
      parameter name: :search, in: :query, type: :string, required: false,
        description: 'Search in campaign titles'
      parameter name: :sort, in: :query, type: :string, required: false,
        description: 'Sort order',
        schema: { type: :string, enum: ['recent', 'trending', 'popular'] }
      parameter name: :page, in: :query, type: :integer, required: false,
        description: 'Page number (default: 1)'
      parameter name: :per_page, in: :query, type: :integer, required: false,
        description: 'Items per page (default: 12, max: 50)'

      response '200', 'successful' do
        schema type: :object,
          properties: {
            campaigns: {
              type: :array,
              items: { '$ref' => '#/components/schemas/Campaign' }
            },
            meta: { '$ref' => '#/components/schemas/PaginationMeta' }
          }

        # Create some test campaigns
        before do
          3.times do |i|
            Campaign.create!(
              creator: user,
              category: category,
              title: "Test Campaign #{i + 1}",
              description: "Description for campaign #{i + 1}",
              goal_amount: 5000,
              status: 'active'
            )
          end
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('campaigns')
          expect(data).to have_key('meta')
          expect(data['campaigns']).to be_an(Array)
          expect(data['campaigns'].length).to be > 0
        end
      end
    end
    
    # ========================================================================
    # POST /api/v1/campaigns - Create Campaign
    # ========================================================================
    
    post 'Create a campaign' do
      tags 'Campaigns'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer_auth: [] }]
      description 'Create a new fundraising campaign'

      parameter name: :campaign, in: :body, schema: {
        type: :object,
        properties: {
          campaign: {
            type: :object,
            properties: {
              title: { type: :string, example: 'Help Fund Medical Treatment' },
              description: { type: :string, example: 'Detailed campaign description...' },
              category_id: { type: :integer, example: 1 },
              goal_amount: { type: :number, example: 5000 },
              status: { type: :string, enum: ['draft', 'active'], example: 'active' }
            },
            required: ['title', 'description', 'category_id', 'goal_amount']
          }
        }
      }

      # Successful creation
      response '201', 'campaign created' do
        schema '$ref' => '#/components/schemas/Campaign'

        let(:campaign) do
          {
            campaign: {
              title: 'Help Fund Medical Treatment',
              description: 'My mother needs urgent medical care.',
              category_id: category.id,
              goal_amount: 5000,
              status: 'active'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['title']).to eq('Help Fund Medical Treatment')
          expect(data['status']).to eq('active')
          expect(data['creator']['id']).to eq(user.id)
        end
      end

      # Unauthorized (no token)
      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:campaign) do
          {
            campaign: {
              title: 'Test Campaign',
              description: 'Test',
              category_id: category.id,
              goal_amount: 1000
            }
          }
        end

        run_test!
      end

      # Validation error
      response '422', 'invalid request' do
        schema '$ref' => '#/components/schemas/Error'

        let(:campaign) do
          {
            campaign: {
              title: '',  # Invalid: blank title
              description: 'Test',
              category_id: category.id,
              goal_amount: -100  # Invalid: negative amount
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
        end
      end
    end
  end

  path '/api/v1/campaigns/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Campaign ID'

    let!(:campaign) do
      Campaign.create!(
        creator: user,
        category: category,
        title: 'Existing Campaign',
        description: 'Campaign description',
        goal_amount: 5000
      )
    end
    let(:id) { campaign.id }
    
    # ========================================================================
    # GET /api/v1/campaigns/:id - Show Campaign
    # ========================================================================
    
    get 'Show campaign details' do
      tags 'Campaigns'
      produces 'application/json'
      description 'Retrieve detailed information about a specific campaign'

      response '200', 'successful' do
        schema '$ref' => '#/components/schemas/Campaign'

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(campaign.id)
          expect(data['title']).to eq('Existing Campaign')
          expect(data).to have_key('creator')
          expect(data).to have_key('description_html')
        end
      end

      response '404', 'not found' do
        let(:id) { 999999 }
        run_test!
      end
    end
    
    # ========================================================================
    # PATCH /api/v1/campaigns/:id - Update Campaign
    # ========================================================================
    
    patch 'Update campaign' do
      tags 'Campaigns'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer_auth: [] }]
      description 'Update campaign details (only by creator)'

      parameter name: :campaign, in: :body, schema: {
        type: :object,
        properties: {
          campaign: {
            type: :object,
            properties: {
              title: { type: :string },
              description: { type: :string },
              goal_amount: { type: :number },
              status: { type: :string }
            }
          }
        }
      }

      response '200', 'campaign updated' do
        let(:campaign) do
          {
            campaign: {
              title: 'Updated Title',
              goal_amount: 7500
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['title']).to eq('Updated Title')
          expect(data['goal_amount']).to eq(7500.0)
        end
      end

      response '403', 'forbidden (not creator)' do
        # Create another user
        let!(:other_user) do
          User.create!(
            email_address: 'other@example.com',
            password: 'password123',
            password_confirmation: 'password123',
            first_name: 'Bob',
            last_name: 'Jones',
            phone_number: '+1555555555'
          )
        end
        let(:Authorization) { "Bearer #{other_user.sessions.create!.token}" }
        let(:campaign) { { campaign: { title: 'Hacked' } } }

        run_test!
      end
    end
    
    # ========================================================================
    # DELETE /api/v1/campaigns/:id - Cancel Campaign
    # ========================================================================
    
    delete 'Cancel campaign' do
      tags 'Campaigns'
      security [{ bearer_auth: [] }]
      description 'Cancel campaign (changes status to cancelled)'

      response '204', 'campaign cancelled' do
        run_test! do
          # Verify campaign was cancelled
          campaign.reload
          expect(campaign.status).to eq('cancelled')
        end
      end

      response '403', 'forbidden (not creator)' do
        let!(:other_user) do
          User.create!(
            email_address: 'other2@example.com',
            password: 'password123',
            password_confirmation: 'password123',
            first_name: 'Alice',
            last_name: 'Williams',
            phone_number: '+1666666666'
          )
        end
        let(:Authorization) { "Bearer #{other_user.sessions.create!.token}" }

        run_test!
      end
    end
  end
end