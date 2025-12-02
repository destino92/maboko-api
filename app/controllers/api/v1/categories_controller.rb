# app/controllers/api/v1/categories_controller.rb
module Api
  module V1
    class CategoriesController < ApplicationController
      allow_unauthenticated_access only: [:index, :show]

      def index
        categories = Category.order(:name)
        render json: categories.map { |c| CategorySerializer.new(c).as_json }
      end

      def show
        category = Category.find_by!(slug: params[:id])
        render json: CategorySerializer.new(category).as_json
      end
    end
  end
end