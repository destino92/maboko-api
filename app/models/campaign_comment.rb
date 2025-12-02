# app/models/campaign_comment.rb
class CampaignComment < ApplicationRecord
  belongs_to :campaign
  belongs_to :user
  
  enum :comment_type, {
    comment: "comment",  # Regular comment from anyone
    update: "update"     # Official update from campaign creator
  }, default: :comment
  
  validates :content, 
    presence: true,
    length: { maximum: 5000 }
  
  # Only campaign creator can post updates
  validate :updates_only_by_creator, if: :update?
  
  private
  
  def updates_only_by_creator
    if user_id != campaign.creator_id
      errors.add(:base, "Only campaign creator can post updates")
    end
  end
end
