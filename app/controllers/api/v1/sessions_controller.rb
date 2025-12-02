# app/controllers/api/v1/sessions_controller.rb
module Api
  module V1
    class SessionsController < ApplicationController
      # Allow anyone to create a session (login)
      # Don't require authentication for login (that would be circular!)
      allow_unauthenticated_access only: [:create]
      
      # POST /api/v1/session
      # Login endpoint
      # Expects: { "email_address": "...", "password": "..." }
      def create
        # authenticate_by is a Rails helper that:
        # 1. Finds user by email_address
        # 2. Checks if password matches
        # 3. Returns user if valid, nil if not
        if user = User.authenticate_by(
          email_address: params[:email_address], 
          password: params[:password]
        )
          # Password correct! Create a session
          start_new_session_for(user)
          
          # Return success with token and user info
          render json: {
            message: "Logged in successfully",
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
          # Email or password incorrect
          render json: { 
            error: "Invalid credentials",
            message: "Email or password is incorrect" 
          }, status: :unauthorized
        end
      end
      
      # DELETE /api/v1/session
      # Logout endpoint
      # Requires: Authorization: Bearer <token>
      def destroy
        # Destroy the current session
        terminate_session
        
        render json: { 
          message: "Logged out successfully" 
        }, status: :ok
      end
    end
  end
end