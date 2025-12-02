class Campaign < ApplicationRecord
  # A campaign belongs to a creator (User)
  belongs_to :creator
  # A campaign belongs to a category
  belongs_to :category
  # A campaign has rich text description (uses Action Text)
  has_rich_text :description
  # A campaign has one cover image (uses Active Storage)
  has_one_attached :cover_image
  # A campaign has many contributions
  has_many :contributions, dependent: :destroy

  # A campaign has many contributors (Users who contributed)
  # Through: contributions (join table)
  has_many :contributors, through: :contributions, source: :contributor
  
  # A campaign tracks views
  has_many :campaign_views, dependent: :destroy
  
  # A campaign can have subscribers
  has_many :subscriptions, dependent: :destroy
  has_many :subscribers, through: :subscriptions, source: :user
  
  # A campaign can have comments and updates
  has_many :campaign_comments, dependent: :destroy
  
  # A campaign can have payout requests
  has_many :payout_requests, dependent: :destroy
  
  # ============================================================================
  # ENUMS (Pre-defined values for status field)
  # ============================================================================
  
  # Status can only be one of these values
  enum :status, {
    draft: "draft",         # Not yet published
    active: "active",       # Live and accepting donations
    completed: "completed", # Goal reached or campaign ended
    cancelled: "cancelled"  # Cancelled by creator
  }, default: :active
  
  # This creates methods like:
  # - campaign.active? → true/false
  # - campaign.draft! → changes status to draft
  # - Campaign.active → query for all active campaigns
  
  # ============================================================================
  # VALIDATIONS (Data quality rules)
  # ============================================================================
  
  validates :title, 
    presence: true,                    # Required
    length: { minimum: 5, maximum: 100 }  # Must be 5-100 characters
  
  validates :goal_amount, 
    presence: true,
    numericality: { greater_than: 0 }  # Must be positive number

  validates :current_amount, 
    presence: true
  
  validates :description, presence: true
  
  # Custom validation
  validate :cover_image_type, if: -> { cover_image.attached? }
  
  # ============================================================================
  # SCOPES (Pre-defined queries)
  # ============================================================================
  
  # Scopes are like saved queries you can chain together
  
  # Get only active campaigns
  scope :active, -> { where(status: "active") }
  
  # Order by newest first
  scope :recent, -> { order(created_at: :desc) }
  
  # Filter by category
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  
  # Order by amount raised (trending)
  scope :trending, -> { order(current_amount: :desc) }
  
  # Order by view count (popular)
  scope :popular, -> { order(view_count: :desc) }
  
  # Usage: Campaign.active.recent.by_category(1)
  # This chains scopes to build: WHERE status = 'active' AND category_id = 1 ORDER BY created_at DESC
  
  # ============================================================================
  # INSTANCE METHODS (Functions that work on a specific campaign)
  # ============================================================================
  
  # Calculate funding percentage
  # Example: campaign.progress_percentage → 75.5
  def progress_percentage
    return 0 if goal_amount.zero?
    ((current_amount / goal_amount) * 100).round(2)
  end
  
  # Count unique contributors
  def contributor_count
    contributions.succeeded.distinct.count(:contributor_id)
  end
  
  # Increment view count (called when someone views the campaign)
  def increment_view_count!
    increment!(:view_count)
  end
  
  # Check if goal is reached
  def goal_reached?
    current_amount >= goal_amount
  end
  
  # Check if campaign is editable by user
  def editable_by?(user)
    creator_id == user&.id && (draft? || active?)
  end
  
  private
  
  # ============================================================================
  # PRIVATE METHODS (Internal validation helpers)
  # ============================================================================
  
  # Validate cover image is an image file
  def cover_image_type
    # Allowed types: JPEG, PNG, GIF, WebP
    allowed_types = %w[image/jpeg image/png image/gif image/webp]
    
    unless cover_image.content_type.in?(allowed_types)
      errors.add(:cover_image, "must be a JPEG, PNG, GIF, or WebP image")
    end
    
    # Check file size (max 5MB)
    if cover_image.byte_size > 5.megabytes
      errors.add(:cover_image, "must be less than 5MB")
    end
  end
end
