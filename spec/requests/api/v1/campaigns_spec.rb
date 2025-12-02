# spec/requests/api/v1/campaigns_spec.rb
require 'swagger_helper'

RSpec.describe 'Campaigns API', type: :request, openapi_spec: 'v1/openapi.yaml' do
  let(:category) { Category.create!(name: 'Medical', slug: 'medical') }
  let(:user) { User.create!(
    email_address: 'test@example.com',
    password: 'password',
    password_confirmation: 'password',
    first_name: 'John',
    last_name: 'Doe',
    phone_number: '+1234567890'
  )}
  let(:session) { user.sessions.create! }
  let(:Authorization) { "Bearer #{session.token}" }

  path '/api/v1/campaigns' do
    get 'List campaigns' do
      tags 'Campaigns'
      produces 'application/json'
      
      parameter name: :category_id, in: :query, type: :integer, required: false, description: 'Filter by category ID'
      parameter name: :search, in: :query, type: :string, required: false, description: 'Search in campaign titles'
      parameter name: :sort, in: :query, type: :string, required: false, description: 'Sort order (recent, trending, popular)'
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Items per page'

      response '200', 'successful' do
        schema type: :object,
          properties: {
            campaigns: {
              type: :array,
              items: { '$ref' => '#/components/schemas/Campaign' }
            },
            meta: {
              type: :object,
              properties: {
                current_page: { type: :integer },
                total_pages: { type: :integer },
                total_count: { type: :integer },
                per_page: { type: :integer }
              }
            }
          }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('campaigns')
          expect(data).to have_key('meta')
        end
      end
    end

    post 'Create a campaign' do
      tags 'Campaigns'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      parameter name: :campaign, in: :body, schema: {
        type: :object,
        properties: {
          campaign: {
            type: :object,
            properties: {
              title: { type: :string },
              description: { type: :string },
              category_id: { type: :integer },
              goal_amount: { type: :number },
              status: { type: :string, enum: ['draft', 'active'] }
            },
            required: ['title', 'description', 'category_id', 'goal_amount']
          }
        }
      }

      response '201', 'campaign created' do
        let(:campaign) do
          {
            campaign: {
              title: 'Help Fund Medical Treatment',
              description: 'Need help with medical bills',
              category_id: category.id,
              goal_amount: 5000,
              status: 'active'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['title']).to eq('Help Fund Medical Treatment')
        end
      end

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

      response '422', 'invalid request' do
        let(:campaign) do
          {
            campaign: {
              title: '',
              description: 'Test',
              category_id: category.id,
              goal_amount: -100
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/campaigns/{id}' do
    parameter name: :id, in: :path, type: :integer

    get 'Show campaign details' do
      tags 'Campaigns'
      produces 'application/json'

      let(:campaign) { Campaign.create!(
        creator: user,
        category: category,
        title: 'Test Campaign',
        description: 'Test description',
        goal_amount: 5000
      )}
      let(:id) { campaign.id }

      response '200', 'successful' do
        schema '$ref' => '#/components/schemas/Campaign'

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(campaign.id)
        end
      end

      response '404', 'not found' do
        let(:id) { 999999 }
        run_test!
      end
    end

    put 'Update campaign' do
      tags 'Campaigns'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer_auth: [] }]

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

      let(:existing_campaign) { Campaign.create!(
        creator: user,
        category: category,
        title: 'Original Title',
        description: 'Original description',
        goal_amount: 1000
      )}
      let(:id) { existing_campaign.id }

      response '200', 'campaign updated' do
        let(:campaign) do
          {
            campaign: {
              title: 'Updated Title',
              goal_amount: 2000
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['title']).to eq('Updated Title')
        end
      end

      response '403', 'forbidden' do
        let(:other_user) { User.create!(
          email_address: 'other@example.com',
          password: 'password',
          password_confirmation: 'password',
          first_name: 'Jane',
          last_name: 'Smith',
          phone_number: '+9876543210'
        )}
        let(:Authorization) { "Bearer #{other_user.sessions.create!.token}" }
        let(:campaign) do
          {
            campaign: { title: 'Hacked' }
          }
        end

        run_test!
      end
    end

    delete 'Cancel campaign' do
      tags 'Campaigns'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      let(:existing_campaign) { Campaign.create!(
        creator: user,
        category: category,
        title: 'To be cancelled',
        description: 'Test',
        goal_amount: 1000
      )}
      let(:id) { existing_campaign.id }

      response '204', 'campaign cancelled' do
        run_test!
      end

      response '403', 'forbidden' do
        let(:other_user) { User.create!(
          email_address: 'other@example.com',
          password: 'password',
          password_confirmation: 'password',
          first_name: 'Jane',
          last_name: 'Smith',
          phone_number: '+9876543210'
        )}
        let(:Authorization) { "Bearer #{other_user.sessions.create!.token}" }

        run_test!
      end
    end
  end
end