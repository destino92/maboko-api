# app/controllers/api/v1/passwords_controller.rb
module Api
  module V1
    class PasswordsController < ApplicationController
      allow_unauthenticated_access only: [:create, :update]
      before_action :set_user_by_token, only: [:update]

      def create
        if user = User.find_by(email_address: params[:email_address])
          PasswordsMailer.reset(user).deliver_later
        end
        render json: { message: "Password reset instructions sent if email exists" }
      end

      def update
        if @user.update(password_params)
          @user.sessions.destroy_all
          render json: { message: "Password has been reset successfully" }
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_user_by_token
        @user = User.find_by_password_reset_token!(params[:token])
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        render json: { errors: ["Password reset link is invalid or expired"] }, status: :unauthorized
      end

      def password_params
        params.require(:user).permit(:password, :password_confirmation)
      end
    end
  end
end