# app/controllers/api/v1/subscriptions_controller.rb
module Api
  module V1
    class SubscriptionsController < ApplicationController
      before_action :set_campaign

      def create
        subscription = @campaign.subscriptions.build(
          user: current_user,
          subscribed_at: Time.current
        )

        if subscription.save
          render json: { message: "Successfully subscribed to campaign updates" }, status: :created
        else
          render json: { errors: subscription.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        subscription = @campaign.subscriptions.find_by!(user: current_user)
        subscription.destroy
        head :no_content
      end

      private

      def set_campaign
        @campaign = Campaign.find(params[:campaign_id])
      end
    end
  end
end