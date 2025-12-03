# spec/swagger_helper.rb
require 'rails_helper'

RSpec.configure do |config|
  # Specify where to save generated OpenAPI files
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define OpenAPI specifications
  config.openapi_specs = {
    'v1/openapi.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'CrowdShare API V1',
        version: 'v1',
        description: 'API for CrowdShare - A fundraising platform for personal causes',
        contact: {
          name: 'CrowdShare Support',
          email: 'support@crowdshare.com'
        },
        license: {
          name: 'MIT',
          url: 'https://opensource.org/licenses/MIT'
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
        # Security schemes for authentication
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'Token',
            description: 'Session token obtained from login endpoint'
          }
        },
        
        # Reusable schemas
        schemas: {
          # User schema
          User: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              email_address: { type: :string, format: :email, example: 'user@example.com' },
              first_name: { type: :string, example: 'John' },
              last_name: { type: :string, example: 'Doe' },
              full_name: { type: :string, example: 'John Doe' },
              phone_number: { type: :string, example: '+1234567890' }
            },
            required: ['id', 'email_address', 'first_name', 'last_name']
          },
          
          # Category schema
          Category: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              name: { type: :string, example: 'Medical' },
              slug: { type: :string, example: 'medical' },
              campaigns_count: { type: :integer, example: 25 }
            },
            required: ['id', 'name', 'slug']
          },
          
          # Campaign schema
          Campaign: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              title: { type: :string, example: 'Help Fund Medical Treatment' },
              description: { type: :string, example: 'Campaign description...' },
              goal_amount: { type: :number, format: :float, example: 5000.0 },
              current_amount: { type: :number, format: :float, example: 2500.0 },
              progress_percentage: { type: :number, format: :float, example: 50.0 },
              status: { 
                type: :string, 
                enum: ['draft', 'active', 'completed', 'cancelled'],
                example: 'active'
              },
              view_count: { type: :integer, example: 150 },
              contributor_count: { type: :integer, example: 25 },
              cover_image_url: { type: :string, format: :uri, nullable: true },
              category: { '$ref' => '#/components/schemas/Category' },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: ['id', 'title', 'goal_amount', 'status']
          },
          
          # Contribution schema
          Contribution: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              amount: { type: :number, format: :float, example: 100.0 },
              status: { 
                type: :string,
                enum: ['pending', 'succeeded', 'failed', 'refunded'],
                example: 'succeeded'
              },
              contributed_at: { type: :string, format: 'date-time' },
              contributor: { '$ref' => '#/components/schemas/User' }
            },
            required: ['id', 'amount', 'status']
          },
          
          # Error response schema
          Error: {
            type: :object,
            properties: {
              error: { type: :string, example: 'Validation Failed' },
              message: { type: :string, example: 'The request could not be processed' },
              errors: { 
                type: :array, 
                items: { type: :string },
                example: ["Email can't be blank", "Password is too short"]
              }
            }
          },
          
          # Pagination metadata
          PaginationMeta: {
            type: :object,
            properties: {
              current_page: { type: :integer, example: 1 },
              total_pages: { type: :integer, example: 5 },
              total_count: { type: :integer, example: 50 },
              per_page: { type: :integer, example: 12 }
            }
          }
        }
      }
    }
  }

  # Specify output format (yaml or json)
  config.openapi_format = :yaml
end