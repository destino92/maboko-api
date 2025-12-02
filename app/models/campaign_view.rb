class CampaignView < ApplicationRecord
  belongs_to :campaign

  validates :viewed_at, presence: true
  
  # After creating a view, increment campaign's view_count
  after_create :increment_campaign_view_count
  
  private
  
  def increment_campaign_view_count
    campaign.increment_view_count!
  end
end
