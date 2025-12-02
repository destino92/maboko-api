# app/controllers/api/v1/campaign_comments_controller.rb
module Api
  module V1
    class CampaignCommentsController < ApplicationController
      before_action :set_campaign
      before_action :authorize_campaign_owner_for_updates, only: [:create], if: -> { params[:comment_type] == "update" }

      def index
        comments = @campaign.campaign_comments
                           .includes(:user)
                           .order(created_at: :desc)

        # Filter by type
        comments = comments.where(comment_type: params[:type]) if params[:type].present?

        page = params[:page] || 1
        per_page = params[:per_page] || 20

        pagy, comments = pagy(comments, page: page, items: per_page)

        render json: {
          comments: comments.map { |c| CampaignCommentSerializer.new(c).as_json },
          meta: pagy_metadata(pagy)
        }
      end

      def create
        comment = @campaign.campaign_comments.build(comment_params)
        comment.user = current_user

        if comment.save
          # Notify subscribers if this is an update
          notify_subscribers if comment.update?
          render json: CampaignCommentSerializer.new(comment).as_json, status: :created
        else
          render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_campaign
        @campaign = Campaign.find(params[:campaign_id])
      end

      def authorize_campaign_owner_for_updates
        unless @campaign.creator_id == current_user.id
          render json: { error: "Only campaign owner can post updates" }, status: :forbidden
        end
      end

      def comment_params
        params.require(:campaign_comment).permit(:content, :comment_type)
      end

      def notify_subscribers
        @campaign.subscribers.each do |subscriber|
          CampaignMailer.campaign_update(subscriber, @campaign).deliver_later
        end
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