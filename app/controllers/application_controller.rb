# frozen_string_literal: true

class ApplicationController < ActionController::API
  def authenticate_user!
    api_key = ApiKey.find_by(token: request.session[:token])
    @current_user = api_key&.bearer
    return unless @current_user.nil?

    head :unauthorized if @current_user.nil? && !@current_user
  end
end
