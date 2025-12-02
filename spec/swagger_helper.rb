# spec/swagger_helper.rb
require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s

  config.openapi_specs = {
    'v1/openapi.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'CrowdShare API V1',
        version: 'v1',
        description: 'API documentation for CrowdShare fundraising platform',
        contact: {
          name: 'CrowdShare Team',
          email: 'support@crowdshare.com'
        }
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        },
        {
          url: 'https://api.crowdshare.com',
          description: 'Production server'
        }
      ],
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'Token',
            description: 'Enter your session token'
          }
        },
        schemas: {
          User: {
            type: :object,
            properties: {
              id: { type: :integer },
              email_address: { type: :string },
              first_name: { type: :string },
              last_name: { type: :string },
              full_name: { type: :string },
              phone_number: { type: :string }
            },
            required: ['id', 'email_address', 'first_name', 'last_name']
          },
          Category: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              slug: { type: :string }
            },
            required: ['id', 'name', 'slug']
          },
          Campaign: {
            type: :object,
            properties: {
              id: { type: :integer },
              title: { type: :string },
              description: { type: :string },
              goal_amount: { type: :number },
              current_amount: { type: :number },
              progress_percentage: { type: :number },
              status: { type: :string, enum: ['draft', 'active', 'completed', 'cancelled'] },
              view_count: { type: :integer },
              contributor_count: { type: :integer },
              cover_image_url: { type: :string, nullable: true },
              category: { '$ref' => '#/components/schemas/Category' },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: ['id', 'title', 'goal_amount', 'status']
          },
          Contribution: {
            type: :object,
            properties: {
              id: { type: :integer },
              amount: { type: :number },
              status: { type: :string, enum: ['pending', 'succeeded', 'failed', 'refunded'] },
              contributed_at: { type: :string, format: 'date-time' },
              contributor: { '$ref' => '#/components/schemas/User' }
            },
            required: ['id', 'amount', 'status']
          },
          Error: {
            type: :object,
            properties: {
              error: { type: :string },
              errors: { type: :array, items: { type: :string } }
            }
          }
        }
      }
    }
  }

  config.openapi_format = :yaml
end