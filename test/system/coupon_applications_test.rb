require "application_system_test_case"

class CouponApplicationsTest < ApplicationSystemTestCase
  setup do
    @product = products(:ruby_guide)
    visit root_path
    Capybara.reset_sessions!
  end

  def add_to_cart(product)
    visit product_path(product)
    click_on "Add to Cart"
  end

  def apply_coupon(code)
    visit cart_path
    fill_in "coupon_code", with: code
    click_on "Terapkan"
  end

  test "apply valid percent coupon to cart" do
    coupon = Coupon.create!(
      code: "PERCENT10",
      discount_type: "percent_cart",
      discount_amount: 10,
      state: "active"
    )

    add_to_cart(@product)
    apply_coupon("PERCENT10")

    assert_text "Kupon terpasang: PERCENT10"
    assert_text "Diskon"
  end

  test "apply invalid coupon shows error" do
    add_to_cart(@product)

    visit cart_path
    fill_in "coupon_code", with: "INVALID"
    click_on "Terapkan"

    assert_text "is invalid or cannot be applied"
  end

  test "apply expired coupon shows error" do
    coupon = Coupon.create!(
      code: "EXPIRED",
      discount_type: "percent_cart",
      discount_amount: 10,
      state: "active",
      expires_at: 1.day.ago
    )

    add_to_cart(@product)
    apply_coupon("EXPIRED")

    assert_text "is invalid or cannot be applied"
  end

  test "apply inactive coupon shows error" do
    coupon = Coupon.create!(
      code: "INACTIVE",
      discount_type: "percent_cart",
      discount_amount: 10,
      state: "inactive"
    )

    add_to_cart(@product)
    apply_coupon("INACTIVE")

    assert_text "is invalid or cannot be applied"
  end

  test "coupon below minimum amount shows error" do
    coupon = Coupon.create!(
      code: "MIN100K",
      discount_type: "percent_cart",
      discount_amount: 10,
      state: "active",
      minimum_amount: 100_000
    )

    add_to_cart(@product)
    apply_coupon("MIN100K")

    assert_text "is invalid or cannot be applied"
  end

  test "remove coupon from cart" do
    coupon = Coupon.create!(
      code: "REMOVE10",
      discount_type: "percent_cart",
      discount_amount: 10,
      state: "active"
    )

    add_to_cart(@product)
    apply_coupon("REMOVE10")

    assert_text "REMOVE10"

    click_on "Hapus Kupon"

    assert_no_text "REMOVE10"
  end

  test "fixed coupon discount reflects in cart total" do
    product = products(:ruby_guide)

    coupon = Coupon.create!(
      code: "FIXED5K",
      discount_type: "fixed_cart",
      discount_amount: 5000,
      state: "active"
    )

    add_to_cart(product)
    apply_coupon("FIXED5K")

    assert_text "FIXED5K"
  end

  test "free shipping coupon removes shipping cost" do
    physical_product = products(:premium_t_shirt)
    variant = product_variants(:t_shirt_red_small)

    coupon = Coupon.create!(
      code: "FREESHIP",
      discount_type: "free_shipping",
      state: "active"
    )

    visit product_path(physical_product)
    select variant.name, from: "Pilih Variasi"
    click_on "Add to Cart"

    apply_coupon("FREESHIP")

    assert_text "FREESHIP"
  end

  test "coupon with usage limit shows error after limit reached" do
    coupon = Coupon.create!(
      code: "LIMIT1",
      discount_type: "percent_cart",
      discount_amount: 10,
      state: "active",
      usage_limit: 1,
      usage_count: 1
    )

    add_to_cart(@product)
    apply_coupon("LIMIT1")

    assert_text "is invalid or cannot be applied"
  end

  test "coupon persists through checkout process" do
    coupon = Coupon.create!(
      code: "CHECKOUT10",
      discount_type: "percent_cart",
      discount_amount: 10,
      state: "active"
    )

    add_to_cart(@product)
    apply_coupon("CHECKOUT10")

    assert_text "CHECKOUT10"

    fill_in "customer_name", with: "Test User"
    fill_in "customer_email_address", with: "test@example.com"
    check "customer_agree_to_terms"

    click_on "Lanjut ke Checkout"

    assert_current_path new_order_path
  end

  test "admin can create new coupon" do
    visit new_admin_coupon_path

    fill_in "Code", with: "NEWCOUPON"
    fill_in "Description", with: "Test coupon"
    select "Fixed Cart Discount", from: "Discount type"
    fill_in "Discount amount", with: "10000"
    select "active", from: "State"

    click_on "Save Coupon"

    assert_text "Coupon created successfully"
    assert_current_path admin_coupons_path
  end

  test "admin can edit existing coupon" do
    coupon = coupons(:active_fixed_cart)

    visit edit_admin_coupon_path(coupon)

    fill_in "Description", with: "Updated description"
    click_on "Save Coupon"

    assert_text "Coupon updated successfully"
  end

  test "admin can delete coupon" do
    coupon = Coupon.create!(
      code: "DELETEME",
      discount_type: "percent_cart",
      discount_amount: 10,
      state: "active"
    )

    visit admin_coupons_path

    accept_alert do
      click_on "Delete", match: :first
    end

    assert_no_text "DELETEME"
  end

  test "admin can activate coupon" do
    coupon = Coupon.create!(
      code: "ACTIVATEME",
      discount_type: "percent_cart",
      discount_amount: 10,
      state: "inactive"
    )

    visit admin_coupons_path
    click_on "Activate", match: :first

    assert_text "Coupon activated"
  end

  test "admin can deactivate coupon" do
    coupon = Coupon.create!(
      code: "DEACTIVATEME",
      discount_type: "percent_cart",
      discount_amount: 10,
      state: "active"
    )

    visit admin_coupons_path
    click_on "Deactivate", match: :first

    assert_text "Coupon deactivated"
  end

  test "admin dashboard displays coupon statistics" do
    coupon = Coupon.create!(
      code: "STATS",
      discount_type: "percent_cart",
      discount_amount: 10,
      state: "active"
    )

    visit admin_coupons_path
    assert_text "STATS"

    visit admin_path
    assert_text "Kupon"
    assert_text "total kupon"
  end

  test "order show displays coupon information" do
    product = products(:ruby_guide)
    coupon = Coupon.create!(
      code: "ORDERCOUPON",
      discount_type: "fixed_cart",
      discount_amount: 5000,
      state: "active"
    )

    add_to_cart(product)
    apply_coupon("ORDERCOUPON")

    fill_in "customer_name", with: "Test User"
    fill_in "customer_email_address", with: "test@example.com"
    check "customer_agree_to_terms"

    click_on "Lanjut ke Checkout"
  end
end
