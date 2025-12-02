class ApplicationController < ActionController::API
  # Include token authentication helper
  include ActionController::HttpAuthentication::Token::ControllerMethods
  
  # Include our custom authentication logic
  include Authentication

  # If a record isn't found (e.g., Campaign.find(999))
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  
  # If validation fails (e.g., user.save! with invalid data)
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity

  private
  
  def render_not_found
    render json: { 
      error: "Not Found",
      message: "The requested resource could not be found"
    }, status: :not_found
  end
  
  def render_unprocessable_entity(exception)
    render json: { 
      error: "Validation Failed",
      errors: exception.record.errors.full_messages 
    }, status: :unprocessable_entity
  end
end
