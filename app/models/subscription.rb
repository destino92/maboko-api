class Subscription < ApplicationRecord
  belongs_to :campaign
  belongs_to :user

  validates :subscribed_at, presence: true
  validates :user_id, uniqueness: { 
    scope: :campaign_id,
    message: "is already subscribed to this campaign" 
  }
end
