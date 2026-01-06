require "test_helper"

class Admin::DonationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @donation = donations(:pending_donation)
    @admin_auth = ActionController::HttpAuthentication::Basic.encode_credentials("admin", "admin123")
  end

  test "should get index" do
    get admin_donations_path, headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    assert_response :success
  end

  test "should show donations in descending order" do
    get admin_donations_path, headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    assert_response :success
  end

  test "should show donation" do
    get admin_donation_path(@donation), headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_donation_path(@donation), headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    assert_response :success
  end

  test "should update donation" do
    patch admin_donation_path(@donation), params: {
      donation: {
        name: "Updated Name",
        amount: 150000
      }
    }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_redirected_to admin_donation_path(@donation)
    assert_equal "Updated Name", @donation.reload.name
    assert_equal 150000, @donation.reload.amount
  end

  test "should update donation state" do
    patch admin_donation_path(@donation), params: {
      donation: { state: "paid" }
    }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_redirected_to admin_donation_path(@donation)
    assert_equal "paid", @donation.reload.state
  end

  test "should update donation remark" do
    patch admin_donation_path(@donation), params: {
      donation: { remark: "Test remark" }
    }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_equal "Test remark", @donation.reload.remark
  end

  test "should mark evidences as checked when state changes" do
    evidence = @donation.payment_evidences.create(file: fixture_file_upload("test.pdf", "application/pdf"), checked: false)

    patch admin_donation_path(@donation), params: {
      donation: { state: "paid" }
    }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert evidence.reload.checked?
  end

  test "should not mark evidences as checked when state does not change" do
    evidence = @donation.payment_evidences.create(file: fixture_file_upload("test.pdf", "application/pdf"), checked: false)

    patch admin_donation_path(@donation), params: {
      donation: { name: "Updated Name" }
    }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_not evidence.reload.checked?
  end

  test "should destroy donation" do
    assert_difference("Donation.count", -1) do
      delete admin_donation_path(@donation), headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    end

    assert_redirected_to admin_donations_path
  end

  test "should require authentication" do
    get admin_donations_path
    assert_response :unauthorized
  end

  test "should reject invalid credentials" do
    invalid_auth = ActionController::HttpAuthentication::Basic.encode_credentials("wrong", "wrong")
    get admin_donations_path, headers: { "HTTP_AUTHORIZATION" => invalid_auth }
    assert_response :unauthorized
  end
end
