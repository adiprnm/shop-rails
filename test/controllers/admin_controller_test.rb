require "test_helper"

class AdminControllerTest < ActionDispatch::IntegrationTest
  setup do
    @username = Setting.admin_username.value
    @password = Setting.admin_password.value
  end

  test "should get admin index with authentication" do
    get admin_index_url, headers: { HTTP_AUTHORIZATION: ActionController::HttpAuthentication::Basic.encode_credentials(@username, @password) }
    assert_response :success
  end

  test "should require authentication for admin index" do
    get admin_index_url
    assert_response :unauthorized
  end

  test "should reject invalid credentials" do
    get admin_index_url, headers: { HTTP_AUTHORIZATION: ActionController::HttpAuthentication::Basic.encode_credentials("wrong", "credentials") }
    assert_response :unauthorized
  end
end
