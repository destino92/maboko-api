# app/services/payments/process_contribution.rb
module Payments
  class ProcessContribution
    attr_reader :contribution, :payment_method_token, :error

    def self.call(contribution:, payment_method_token:)
      new(contribution: contribution, payment_method_token: payment_method_token).call
    end

    def initialize(contribution:, payment_method_token:)
      @contribution = contribution
      @payment_method_token = payment_method_token
      @error = nil
    end

    def call
      return fail!("Invalid contribution") unless contribution.valid?
      return fail!("Payment method required") if payment_method_token.blank?

      begin
        # In production, use real Akieni Pay API
        # For demo/sandbox, simulate payment
        if Rails.env.production? && ENV["AKIENI_API_KEY"].present?
          process_real_payment
        else
          process_sandbox_payment
        end

        contribution.save!
        self
      rescue StandardError => e
        Rails.logger.error("Payment failed: #{e.message}")
        fail!("Payment processing failed: #{e.message}")
      end
    end

    def success?
      error.nil?
    end

    private

    def process_real_payment
      # TODO: Integrate with actual Akieni Pay API
      # response = AkieniPay::Transaction.charge(
      #   amount: (contribution.amount * 100).to_i,
      #   method_token: payment_method_token,
      #   description: "Contribution to #{contribution.campaign.title}"
      # )
      
      # contribution.payment_reference = response.transaction_id
      # contribution.status = response.success? ? :succeeded : :failed
      
      # For now, fallback to sandbox
      process_sandbox_payment
    end

    def process_sandbox_payment
      # Simulate payment processing
      contribution.payment_reference = "sandbox_#{SecureRandom.hex(10)}"
      
      # 95% success rate in sandbox
      contribution.status = rand < 0.95 ? :succeeded : :failed
      
      # Simulate processing delay
      sleep(0.5) if Rails.env.development?
    end

    def fail!(message)
      @error = message
      contribution.status = :failed if contribution.persisted?
      self
    end
  end
end