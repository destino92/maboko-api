class Session < ApplicationRecord
  belongs_to :user

  # Automatically generates a secure random token when creating a session
  # Length: 36 characters (like: "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
  has_secure_token :token, length: 36
  
  # Before destroying a session, clear it from Current
  before_destroy :clear_current_session
  
  private
  
  def clear_current_session
    Current.session = nil if Current.session == self
  end
end
