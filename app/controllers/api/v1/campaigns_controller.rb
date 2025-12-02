# app/controllers/api/v1/campaigns_controller.rb
module Api
  module V1
    class CampaignsController < ApplicationController
      allow_unauthenticated_access only: [:index, :show]
      before_action :set_campaign, only: [:show, :update, :destroy]
      before_action :authorize_campaign_owner, only: [:update, :destroy]

      def index
        campaigns = Campaign.includes(:creator, :category, cover_image_attachment: :blob)
                           .active
                           .recent

        # Filter by category
        campaigns = campaigns.by_category(params[:category_id]) if params[:category_id].present?

        # Simple search
        if params[:search].present?
          campaigns = campaigns.where("title ILIKE ?", "%#{params[:search]}%")
        end

        # Sorting
        campaigns = case params[:sort]
        when "trending"
          campaigns.trending
        when "popular"
          campaigns.popular
        else
          campaigns.recent
        end

        # Pagination
        page = params[:page] || 1
        per_page = params[:per_page] || 12
        
        pagy, campaigns = pagy(campaigns, page: page, items: per_page)
        
        render json: {
          campaigns: campaigns.map { |c| CampaignSerializer.new(c).as_json },
          meta: pagy_metadata(pagy)
        }
      end

      def show
        # Track view
        @campaign.campaign_views.create!(viewed_at: Time.current)

        render json: CampaignSerializer.new(@campaign, detailed: true).as_json
      end

      def create
        campaign = current_user.created_campaigns.build(campaign_params)

        if campaign.save
          attach_cover_image(campaign) if params[:cover_image].present?
          render json: CampaignSerializer.new(campaign).as_json, status: :created
        else
          render json: { errors: campaign.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @campaign.update(campaign_params)
          attach_cover_image(@campaign) if params[:cover_image].present?
          render json: CampaignSerializer.new(@campaign).as_json
        else
          render json: { errors: @campaign.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @campaign.update!(status: :cancelled)
        head :no_content
      end

      private

      def set_campaign
        @campaign = Campaign.find(params[:id])
      end

      def authorize_campaign_owner
        unless @campaign.creator_id == current_user.id
          render json: { error: "Not authorized" }, status: :forbidden
        end
      end

      def campaign_params
        params.require(:campaign).permit(
          :title,
          :description,
          :category_id,
          :goal_amount,
          :status
        )
      end

      def attach_cover_image(campaign)
        campaign.cover_image.attach(params[:cover_image])
      end

      def pagy_metadata(pagy)
        {
          current_page: pagy.page,
          total_pages: pagy.pages,
          total_count: pagy.count,
          per_page: pagy.items
        }
      end
    end
  end
end