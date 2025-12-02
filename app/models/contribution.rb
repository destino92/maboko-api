class Contribution < ApplicationRecord
  belongs_to :campaign
  belongs_to :contributor

  # Enum for payment status
  enum :status, {
    pending: "pending",       # Payment initiated
    succeeded: "succeeded",   # Payment successful
    failed: "failed",         # Payment failed
    refunded: "refunded"      # Payment refunded
  }, default: :pending
  
  # Validations
  validates :amount, 
    presence: true,
    numericality: { greater_than: 0 }
  
  validates :contributed_at, presence: true
  
  # Scopes
  scope :succeeded, -> { where(status: "succeeded") }
  scope :recent, -> { order(contributed_at: :desc) }
  
  # Callbacks
  # After status changes, update campaign's current_amount
  after_update :sync_campaign_amount, if: :saved_change_to_status?
  after_update :send_notifications, if: -> { saved_change_to_status? && succeeded? }
  
  private
  
  def sync_campaign_amount
    if succeeded?
      # Payment succeeded: add to campaign total
      campaign.increment!(:current_amount, amount)
    elsif refunded? && status_previously_was == "succeeded"
      # Payment refunded: subtract from campaign total
      campaign.decrement!(:current_amount, amount)
    end
  end
  
  def send_notifications
    # Send emails in background (don't slow down the request)
    ContributionMailer.notify_campaign_owner(self).deliver_later
    ContributionMailer.notify_contributor(self).deliver_later
  end
end
