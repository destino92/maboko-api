module Authentication
  extend ActiveSupport::Concern

  # Code in this block runs when the module is included in a controller
  included do
    # Before every action, try to resume the session
    before_action :require_authentication
    helper_method :authenticated?
  end

  # Class methods (available on the controller class itself)
  class_methods do
    # Allows specific actions to skip authentication
    # Example: allow_unauthenticated_access only: [:create]
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    # Try to find and restore the user's session from their token
    def authenticated?
      resume_session
    end

    # Extract token from Authorization header and find matching session
    # Expected header: "Authorization: Bearer abc123xyz"
    def find_session_by_token
      # authenticate_with_http_token is a Rails helper that:
      # 1. Reads the Authorization header
      # 2. Extracts the token
      # 3. Passes it to this block
      authenticate_with_http_token do |token, _options|
        Session.find_by(token: token)
      end
    end

    # Ensure user is authenticated, or return 401 error
    def require_authentication
      resume_session || request_authentication
    end

    # Return JSON error when not authenticated
    def render_unauthorized
      render json: { 
        error: "Unauthorized", 
        message: "You must be logged in to access this resource" 
      }, status: :unauthorized
    end

    # Check if there's an authenticated user
  def authenticated?
    resume_session.present?
  end
  
  # Get the current user (from Current.session.user)
  def current_user
    Current.user
  end
  
  # Create a new session for a user (used after login/signup)
  def start_new_session_for(user)
    user.sessions.create!(
      user_agent: request.user_agent,  # Browser/app info
      ip_address: request.remote_ip    # User's IP address
    ).tap do |session|
      # Store in Current so it's available for this request
      Current.session = session
    end
  end
  
  # Destroy the current session (logout)
  def terminate_session
    Current.session&.destroy
    Current.session = nil
  end
end
