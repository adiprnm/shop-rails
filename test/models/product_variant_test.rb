require "test_helper"

class ProductVariantTest < ActiveSupport::TestCase
  setup do
    @variant = ProductVariant.new
  end

  test "should belong to product" do
    assert_respond_to @variant, :product
  end

  test "should require name" do
    assert_not @variant.valid?
    assert_includes @variant.errors[:name], "can't be blank"
  end

  test "should require price" do
    assert_not @variant.valid?
    assert_includes @variant.errors[:price], "can't be blank"
  end

  test "should require stock" do
    @variant.name = "Test"
    @variant.price = 10000
    @variant.weight = 100
    assert_not @variant.valid?
    assert_includes @variant.errors[:stock], "can't be blank"
  end

  test "should not accept negative price" do
    @variant.name = "Test"
    @variant.price = -100
    assert_not @variant.valid?
    assert_includes @variant.errors[:price], "must be greater than or equal to 0"
  end

  test "should not accept negative weight" do
    @variant.name = "Test"
    @variant.price = 10000
    @variant.weight = -100
    @variant.stock = 10
    assert_not @variant.valid?
    assert_includes @variant.errors[:weight], "must be greater than or equal to 0"
  end

  test "should not accept negative stock" do
    @variant.name = "Test"
    @variant.price = 10000
    @variant.weight = 100
    @variant.stock = -10
    assert_not @variant.valid?
    assert_includes @variant.errors[:stock], "must be greater than or equal to 0"
  end

  test "should be valid with valid attributes" do
    physical_product = PhysicalProduct.create(weight: 100, requires_shipping: true)
    product = Product.create(name: "Test Product", slug: "test-product", price: 10000, state: "active", productable: physical_product)
    @variant.name = "Test Variant"
    @variant.price = 10000
    @variant.weight = 100
    @variant.stock = 10
    @variant.is_active = true
    @variant.product = product
    assert @variant.valid?
  end

  test "active scope should return only active variants" do
    physical_product = PhysicalProduct.create(weight: 100, requires_shipping: true)
    product = Product.create(name: "Test Product", slug: "test-product-2", price: 10000, state: "active", productable: physical_product)
    @variant.name = "Active"
    @variant.price = 10000
    @variant.weight = 100
    @variant.stock = 10
    @variant.is_active = true
    @variant.product = product
    @variant.save

    inactive = ProductVariant.create(name: "Inactive", price: 20000, weight: 200, stock: 5, is_active: false, product: product)

    assert_includes ProductVariant.active, @variant
    assert_not_includes ProductVariant.active, inactive
  end

  test "in_stock scope should return only variants with stock" do
    physical_product = PhysicalProduct.create(weight: 100, requires_shipping: true)
    product = Product.create(name: "Test Product", slug: "test-product-3", price: 10000, state: "active", productable: physical_product)
    @variant.name = "In Stock"
    @variant.price = 10000
    @variant.weight = 100
    @variant.stock = 10
    @variant.is_active = true
    @variant.product = product
    @variant.save

    out_of_stock = ProductVariant.create(name: "Out of Stock", price: 20000, weight: 200, stock: 0, is_active: true, product: product)

    assert_includes ProductVariant.in_stock, @variant
    assert_not_includes ProductVariant.in_stock, out_of_stock
  end
end
