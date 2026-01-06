require "test_helper"

class DonationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @donation_params = {
      name: "Test Donor",
      message: "Test message",
      amount: 10000,
      email_address: "donor@example.com"
    }
    Current.settings = { "payment_provider" => "manual" }
    Current.time_zone = "Asia/Jakarta"
  end

  test "should get index" do
    get supports_path
    assert_response :success
  end

  test "should show paid donations in index" do
    get supports_path
    assert_response :success
  end

  test "should not show pending donations in index" do
    get supports_path
    assert_response :success
  end

  test "should show donations in descending order" do
    get supports_path
    assert_response :success
  end

  test "should create donation" do
    assert_difference("Donation.count") do
      post supports_path, params: { donation: @donation_params }
    end

    assert_redirected_to support_path(Donation.last.donation_id)
  end

  test "should redirect to payment gateway after creating donation" do
    Current.settings = { "payment_provider" => "midtrans", "payment_client_secret" => "test_secret" }

    post supports_path, params: { donation: @donation_params }

    assert_redirected_to %r{^https://app.sandbox.midtrans.com/}
  end

  test "should not create donation without name" do
    assert_no_difference("Donation.count") do
      post supports_path, params: { donation: @donation_params.except(:name) }
    end

    assert_redirected_to supports_path
    assert_not_nil flash[:alert]
  end

  test "should not create donation without message" do
    assert_no_difference("Donation.count") do
      post supports_path, params: { donation: @donation_params.except(:message) }
    end

    assert_redirected_to supports_path
    assert_not_nil flash[:alert]
  end

  test "should not create donation without amount" do
    assert_no_difference("Donation.count") do
      post supports_path, params: { donation: @donation_params.except(:amount) }
    end

    assert_redirected_to supports_path
    assert_not_nil flash[:alert]
  end

  test "should not create donation with amount below minimum" do
    assert_no_difference("Donation.count") do
      post supports_path, params: { donation: @donation_params.merge(amount: 1000) }
    end

    assert_redirected_to supports_path
    assert_not_nil flash[:alert]
  end

  test "should create donation with minimum amount" do
    assert_difference("Donation.count") do
      post supports_path, params: { donation: @donation_params.merge(amount: 5000) }
    end

    assert_redirected_to support_path(Donation.last.donation_id)
  end

  test "should create donation without email address" do
    assert_difference("Donation.count") do
      post supports_path, params: { donation: @donation_params.except(:email_address) }
    end

    assert_redirected_to support_path(Donation.last.donation_id)
  end

  test "should show donation" do
    get support_path(donations(:named_donation).donation_id)
    assert_response :success
  end

  test "should mark donation as expired if past expiry time" do
    get support_path(donations(:expired_donation).donation_id)
    assert_response :success
    assert donations(:expired_donation).expired?
  end

  test "should not modify state if not expired" do
    get support_path(donations(:pending_donation).donation_id)
    assert_response :success
    assert donations(:pending_donation).pending?
  end

  test "should create donation with anonymous name" do
    assert_difference("Donation.count") do
      post supports_path, params: { donation: @donation_params.merge(name: "") }
    end

    assert_redirected_to support_path(Donation.last.donation_id)
    assert_equal "Seseorang", Donation.last.name
  end
end
