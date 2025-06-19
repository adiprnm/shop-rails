class AdminController < ApplicationController
  layout "admin"

  before_action :authenticate

  def index
  end

  private
    def authenticate
      authenticate_or_request_with_http_basic do |username, password|
        username == Setting.admin_username.value && password == Setting.admin_password.value
      end
    end
end
