class PayoutRequest < ApplicationRecord
  belongs_to :campaign
  belongs_to :requestor, class_name: "User"

  enum :status, {
    requested: "requested",     # Request submitted
    processing: "processing",   # Being processed
    completed: "completed",     # Payout completed
    failed: "failed"            # Payout failed
  }, default: :requested

  validates :amount, 
    presence: true,
    numericality: { greater_than: 0 }

  validates :requested_at, presence: true
  
  # Custom validation
  validate :amount_cannot_exceed_balance
  validate :must_be_campaign_creator

  private
  
  def amount_cannot_exceed_balance
    if amount.present? && campaign.present? && amount > campaign.current_amount
      errors.add(:amount, "cannot exceed campaign balance of #{campaign.current_amount}")
    end
  end
  
  def must_be_campaign_creator
    if requestor_id.present? && campaign.present? && requestor_id != campaign.creator_id
      errors.add(:requestor, "must be the campaign creator")
    end
  end
end
