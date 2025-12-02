class Category < ApplicationRecord
  # Relationships
  has_many :campaigns, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  
  # Callbacks (run automatically at certain times)
  before_validation :generate_slug, if: -> { slug.blank? }
  
  private
  
  # Generate URL-friendly slug from name
  # "Medical Care" → "medical-care"
  def generate_slug
    self.slug = name.parameterize if name.present?
  end
end
