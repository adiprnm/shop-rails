require "test_helper"

class ProductTest < ActiveSupport::TestCase
  setup do
    @product = products(:ruby_guide)
  end

  test "should be valid with valid attributes" do
    assert @product.valid?
  end

  test "should have productable" do
    assert_respond_to @product, :productable
  end

  test "should have many order_line_items" do
    assert_respond_to @product, :order_line_items
  end

  test "should have many completed_orders" do
    assert_respond_to @product, :completed_orders
  end

  test "should have many categories" do
    assert_respond_to @product, :categories
  end

  test "should have active state" do
    assert_equal "active", @product.state
  end

  test "should have inactive state" do
    @product.state = "inactive"
    assert_equal "inactive", @product.state
  end

  test "should be sale_price? when sale_price is set and within date range" do
    assert products(:ruby_guide).sale_price?
  end

  test "should not be sale_price? when sale_price is nil" do
    assert_not products(:design_collection).sale_price?
  end

  test "should not be sale_price? when sale_price_starts_at is in the future" do
    @product.update(
      sale_price_starts_at: 1.day.from_now,
      sale_price_ends_at: 2.days.from_now
    )
    assert_not @product.sale_price?
  end

  test "should not be sale_price? when sale_price_ends_at is in the past" do
    @product.update(
      sale_price_starts_at: 2.days.ago,
      sale_price_ends_at: 1.day.ago
    )
    assert_not @product.sale_price?
  end

  test "actual_price should return sale_price when on sale" do
    assert_equal 99000, products(:ruby_guide).actual_price
  end

  test "actual_price should return price when not on sale" do
    assert_equal 299000, products(:design_collection).actual_price
  end

  test "self.create_with_productable should create product with DigitalProduct" do
    product_params = {
      name: "New Product",
      slug: "new-product",
      price: 10000,
      state: "active",
      productable_type: "DigitalProduct"
    }
    productable_params = {
      resource_type: "file",
      resource_url: "http://example.com/resource.pdf"
    }

    product = Product.create_with_productable(product_params, productable_params)

    assert product.persisted?
    assert_equal "DigitalProduct", product.productable_type
    assert_not_nil product.productable
  end

  test "should attach featured_image" do
    @product.featured_image.attach(io: File.open(Rails.root.join("test", "fixtures", "files", "test.jpg")), filename: "test.jpg", content_type: "image/jpeg")
    assert @product.featured_image.attached?
  end
end
