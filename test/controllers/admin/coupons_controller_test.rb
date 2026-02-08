require "test_helper"

class Admin::CouponsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @username = Setting.admin_username.value
    @password = Setting.admin_password.value
  end

  test "should get new" do
    get new_admin_coupon_url, headers: { HTTP_AUTHORIZATION: ActionController::HttpAuthentication::Basic.encode_credentials(@username, @password) }
    assert_response :success
  end

  test "should require authentication for new" do
    get new_admin_coupon_url
    assert_response :unauthorized
  end

  test "should create coupon" do
    assert_difference "Coupon.count", 1 do
      post admin_coupons_url, headers: { HTTP_AUTHORIZATION: ActionController::HttpAuthentication::Basic.encode_credentials(@username, @password) },
        params: {
          coupon: {
            code: "TEST20",
            description: "Test coupon",
            discount_type: "fixed_cart",
            discount_amount: 20000,
            state: "active"
          }
        }
      assert_redirected_to admin_coupons_path
    end
  end

  test "should show coupon" do
    coupon = coupons(:active_fixed_cart)
    get admin_coupon_url(coupon), headers: { HTTP_AUTHORIZATION: ActionController::HttpAuthentication::Basic.encode_credentials(@username, @password) }
    assert_response :success
  end

  test "should get edit" do
    coupon = coupons(:active_fixed_cart)
    get edit_admin_coupon_url(coupon), headers: { HTTP_AUTHORIZATION: ActionController::HttpAuthentication::Basic.encode_credentials(@username, @password) }
    assert_response :success
  end

  test "should update coupon" do
    coupon = coupons(:active_fixed_cart)
    patch admin_coupon_url(coupon), headers: { HTTP_AUTHORIZATION: ActionController::HttpAuthentication::Basic.encode_credentials(@username, @password) },
      params: {
        coupon: {
          description: "Updated description"
        }
      }
    assert_redirected_to admin_coupons_path
    coupon.reload
    assert_equal "Updated description", coupon.description
  end

  test "should destroy coupon" do
    coupon = coupons(:active_fixed_cart)
    assert_difference "Coupon.count", -1 do
      delete admin_coupon_url(coupon), headers: { HTTP_AUTHORIZATION: ActionController::HttpAuthentication::Basic.encode_credentials(@username, @password) }
      assert_redirected_to admin_coupons_path
    end
  end

  test "should get index" do
    get admin_coupons_url, headers: { HTTP_AUTHORIZATION: ActionController::HttpAuthentication::Basic.encode_credentials(@username, @password) }
    assert_response :success
  end

  test "should require authentication for index" do
    get admin_coupons_url
    assert_response :unauthorized
  end
end
