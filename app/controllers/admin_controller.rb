class AdminController < ApplicationController
  layout "admin"

  before_action :authenticate
  around_action :use_time_zone

  def index
  end

  private
    def authenticate
      authenticate_or_request_with_http_basic do |username, password|
        username == Setting.admin_username.value && password == Setting.admin_password.value
      end
    end

    def use_time_zone
      Time.use_zone("Asia/Jakarta") { yield }
    end
end
