# app/controllers/api/v1/contributions_controller.rb
module Api
  module V1
    class ContributionsController < ApplicationController
      before_action :set_campaign

      def index
        contributions = @campaign.contributions
                                 .succeeded
                                 .recent
                                 .includes(:contributor)

        page = params[:page] || 1
        per_page = params[:per_page] || 20

        pagy, contributions = pagy(contributions, page: page, items: per_page)

        render json: {
          contributions: contributions.map { |c| ContributionSerializer.new(c).as_json },
          meta: pagy_metadata(pagy)
        }
      end

      def create
        contribution = @campaign.contributions.build(contribution_params)
        contribution.contributor = current_user
        contribution.contributed_at = Time.current

        # Process payment via Akieni Pay (or sandbox)
        result = Payments::ProcessContribution.call(
          contribution: contribution,
          payment_method_token: params[:payment_method_token]
        )

        if result.success?
          render json: ContributionSerializer.new(contribution).as_json, status: :created
        else
          render json: { errors: [result.error] }, status: :unprocessable_entity
        end
      end

      private

      def set_campaign
        @campaign = Campaign.find(params[:campaign_id])
      end

      def contribution_params
        params.require(:contribution).permit(:amount)
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