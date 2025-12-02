class User < ApplicationRecord
  # has_secure_password provides:
  # - password and password_confirmation virtual attributes
  # - Encrypts password and stores in password_digest column
  # - authenticate method to check if password is correct
  has_secure_password

  # Associations (relationships with other models)
  has_many :sessions, dependent: :destroy
  has_many :created_campaigns, class_name: "Campaign", foreign_key: "creator_id", dependent: :destroy
  has_many :contributions, foreign_key: "contributor_id", dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :campaign_comments, dependent: :destroy

  # Validations (rules that data must follow)
  # Email must exist, be unique, and match email format
  validates :email_address, 
    presence: true,                    # Cannot be blank
    uniqueness: true,                  # No duplicates allowed
    format: { 
      with: URI::MailTo::EMAIL_REGEXP, # Must look like an email
      message: "must be a valid email address"
    }
  
  # Required fields
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true, uniqueness: true
  
  # Sex must be one of these values (if provided)
  validates :sex, 
    inclusion: { 
      in: %w[male female other],      # Only these values allowed
      message: "%{value} is not a valid sex" 
    }, 
    allow_nil: true                    # But can be left blank
  
  # Normalization (clean up data before saving)
  # Converts "  JOHN@EXAMPLE.COM  " to "john@example.com"
  normalizes :email_address, with: ->(email) { email.strip.downcase }
  
  # Custom instance methods (functions that work on a user object)
  
  # Returns the user's full name
  # Example: user.full_name => "John Doe"
  def full_name
    "#{first_name} #{last_name}"
  end
  
  # Generates a password reset token that expires in 15 minutes
  def password_reset_token
    generates_token_for(:password_reset, expires_in: 15.minutes)
  end
end
