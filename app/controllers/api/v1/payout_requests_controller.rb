# app/controllers/api/v1/payout_requests_controller.rb
module Api
  module V1
    class PayoutRequestsController < ApplicationController
      before_action :set_campaign
      before_action :authorize_campaign_owner

      def index
        payout_requests = @campaign.payout_requests.order(created_at: :desc)
        render json: payout_requests.map { |pr| PayoutRequestSerializer.new(pr).as_json }
      end

      def create
        payout_request = @campaign.payout_requests.build(payout_request_params)
        payout_request.requestor = current_user
        payout_request.requested_at = Time.current

        if payout_request.save
          # Process payout (sandbox for demo)
          Payments::ProcessPayout.perform_later(payout_request.id)
          render json: PayoutRequestSerializer.new(payout_request).as_json, status: :created
        else
          render json: { errors: payout_request.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_campaign
        @campaign = Campaign.find(params[:campaign_id])
      end

      def authorize_campaign_owner
        unless @campaign.creator_id == current_user.id
          render json: { error: "Not authorized" }, status: :forbidden
        end
      end

      def payout_request_params
        params.require(:payout_request).permit(:amount)
      end
    end
  end
end