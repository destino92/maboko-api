# app/jobs/payments/process_payout_job.rb
module Payments
  class ProcessPayoutJob < ApplicationJob
    queue_as :default

    def perform(payout_request_id)
      payout_request = PayoutRequest.find(payout_request_id)
      
      payout_request.update!(status: :processing, processed_at: Time.current)

      begin
        # In production, use real MoMo API for disbursement
        if Rails.env.production? && ENV["MOMO_API_KEY"].present?
          process_real_payout(payout_request)
        else
          process_sandbox_payout(payout_request)
        end

        payout_request.update!(status: :completed, completed_at: Time.current)
        
        # Send confirmation email
        PayoutMailer.payout_completed(payout_request).deliver_later
      rescue StandardError => e
        Rails.logger.error("Payout failed: #{e.message}")
        payout_request.update!(status: :failed)
        PayoutMailer.payout_failed(payout_request).deliver_later
      end
    end

    private

    def process_real_payout(payout_request)
      # TODO: Integrate with MoMo OpenAPI
      # response = MoMo::Disbursement.create(
      #   amount: (payout_request.amount * 100).to_i,
      #   phone_number: payout_request.requestor.phone_number,
      #   reference: "payout_#{payout_request.id}"
      # )
      
      # payout_request.disbursement_reference = response.reference
      process_sandbox_payout(payout_request)
    end

    def process_sandbox_payout(payout_request)
      # Simulate payout processing
      payout_request.disbursement_reference = "sandbox_payout_#{SecureRandom.hex(10)}"
      sleep(1) if Rails.env.development?
    end
  end
end