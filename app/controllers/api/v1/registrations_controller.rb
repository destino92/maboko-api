# app/controllers/api/v1/registrations_controller.rb
module Api
  module V1
    class RegistrationsController < ApplicationController
      # Allow anyone to create an account
      allow_unauthenticated_access only: [:create]
      
      # POST /api/v1/registrations
      # Sign up endpoint
      def create
        # Build a new user with parameters from request
        user = User.new(user_params)
        
        # Try to save the user
        if user.save
          # Success! Create a session for them
          start_new_session_for(user)
          
          render json: {
            message: "Account created successfully",
            token: Current.session.token,
            user: {
              id: user.id,
              email_address: user.email_address,
              first_name: user.first_name,
              last_name: user.last_name,
              full_name: user.full_name,
              phone_number: user.phone_number
            }
          }, status: :created
        else
          # Validation failed
          render json: { 
            error: "Validation failed",
            errors: user.errors.full_messages 
          }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotUnique
        # Database constraint violation (duplicate email/phone)
        render json: { 
          error: "Account already exists",
          message: "Email or phone number already taken" 
        }, status: :unprocessable_entity
      end
      
      private
      
      # Strong parameters - only allow these fields
      # This prevents users from sending malicious data
      def user_params
        params.require(:user).permit(
          :email_address,
          :password,
          :password_confirmation,
          :first_name,
          :last_name,
          :phone_number,
          :date_of_birth,
          :sex
        )
      end
    end
  end
end