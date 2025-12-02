# app/serializers/campaign_serializer.rb
class CampaignSerializer
  include Typelizer::DSL
  include Rails.application.routes.url_helpers

  attr_reader :campaign, :detailed

  def initialize(campaign, detailed: false)
    @campaign = campaign
    @detailed = detailed
  end

  typelize :integer
  def id
    campaign.id
  end

  typelize :string
  def title
    campaign.title
  end

  typelize :string
  def description
    campaign.description.to_plain_text if campaign.description.present?
  end

  typelize :string
  def description_html
    campaign.description.to_s if detailed && campaign.description.present?
  end

  typelize :number
  def goal_amount
    campaign.goal_amount.to_f
  end

  typelize :number
  def current_amount
    campaign.current_amount.to_f
  end

  typelize :number
  def progress_percentage
    campaign.progress_percentage
  end

  typelize :string
  def status
    campaign.status
  end

  typelize :integer
  def view_count
    campaign.view_count
  end

  typelize :integer
  def contributor_count
    campaign.contributor_count
  end

  typelize :string, null: true
  def cover_image_url
    if campaign.cover_image.attached?
      Rails.application.routes.url_helpers.url_for(campaign.cover_image)
    end
  end

  typelize :string
  def created_at
    campaign.created_at.iso8601
  end

  typelize :string
  def updated_at
    campaign.updated_at.iso8601
  end

  def creator
    UserSerializer.new(campaign.creator).as_json if detailed
  end

  def category
    CategorySerializer.new(campaign.category).as_json
  end

  def as_json
    base = {
      id: id,
      title: title,
      description: description,
      goal_amount: goal_amount,
      current_amount: current_amount,
      progress_percentage: progress_percentage,
      status: status,
      view_count: view_count,
      contributor_count: contributor_count,
      cover_image_url: cover_image_url,
      category: category,
      created_at: created_at,
      updated_at: updated_at
    }

    if detailed
      base.merge!(
        description_html: description_html,
        creator: creator
      )
    end

    base
  end
end