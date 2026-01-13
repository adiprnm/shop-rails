require "test_helper"

class Admin::SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_auth = ActionController::HttpAuthentication::Basic.encode_credentials("admin", "admin123")
  end

  test "should require authentication" do
    get admin_settings_path
    assert_response :unauthorized
  end

  test "should show settings page" do
    get admin_settings_path, headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    assert_response :success
    assert_select "h1", "Pengaturan"
  end

  test "should update settings" do
    patch admin_settings_path, params: {
      site_name: "Updated Site Name",
      payment_provider: "manual"
    }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_redirected_to admin_settings_path
    assert_equal "Pengaturan berhasil diupdate!", flash[:notice]
    assert_equal "Updated Site Name", Setting.site_name.value
    assert_equal "manual", Setting.payment_provider.value
  end

  test "should update rajaongkir api settings" do
    patch admin_settings_path, params: {
      rajaongkir_api_key: "new_api_key",
      rajaongkir_api_host: "https://api.rajaongkir.com"
    }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_redirected_to admin_settings_path
    assert_equal "new_api_key", Setting.rajaongkir_api_key.value
    assert_equal "https://api.rajaongkir.com", Setting.rajaongkir_api_host.value
  end

  test "should update default shipping origin settings" do
    district = districts(:kebon_jeruk)

    patch admin_settings_path, params: {
      default_origin_district_id: district.id
    }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_redirected_to admin_settings_path
    assert_equal district.id.to_s, Setting.default_origin_district_id.value
  end

  test "should update email smtp settings" do
    patch admin_settings_path, params: {
      email_sender_name: "Updated Sender",
      email_sender_email: "updated@example.com",
      smtp_host: "smtp.example.com",
      smtp_port: "587",
      smtp_username: "user",
      smtp_password: "pass"
    }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_redirected_to admin_settings_path
    assert_equal "Updated Sender", Setting.email_sender_name.value
    assert_equal "updated@example.com", Setting.email_sender_email.value
    assert_equal "smtp.example.com", Setting.smtp_host.value
    assert_equal "587", Setting.smtp_port.value
    assert_equal "user", Setting.smtp_username.value
    assert_equal "pass", Setting.smtp_password.value
  end

  test "should update admin account settings" do
    patch admin_settings_path, params: {
      admin_username: "new_admin",
      admin_password: "new_password",
      admin_email: "new_admin@example.com"
    }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_redirected_to admin_settings_path
    assert_equal "new_admin", Setting.admin_username.value
    assert_equal "new_password", Setting.admin_password.value
    assert_equal "new_admin@example.com", Setting.admin_email.value
  end

  test "should display rajaongkir api key field" do
    get admin_settings_path, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_response :success
    assert_select "label[for=rajaongkir_api_key]"
    assert_select "input[name=rajaongkir_api_key][type=text]"
  end

  test "should display rajaongkir api host field" do
    get admin_settings_path, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_response :success
    assert_select "label[for=rajaongkir_api_host]"
    assert_select "input[name=rajaongkir_api_host][type=text]"
  end

  test "should display default origin fields" do
    get admin_settings_path, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_response :success
    assert_select "label[for=default_origin_district_id]"
  end

  test "should update manual payment unique code max setting" do
    patch admin_settings_path, params: {
      manual_payment_unique_code_max: "1000"
    }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_redirected_to admin_settings_path
    assert_equal "1000", Setting.manual_payment_unique_code_max.value
  end

  test "should display manual payment unique code max field" do
    get admin_settings_path, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_response :success
    assert_select "label[for=manual_payment_unique_code_max]"
    assert_select "input[name=manual_payment_unique_code_max][type=number]"
  end
end
