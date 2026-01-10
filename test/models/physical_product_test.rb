require "test_helper"

class PhysicalProductTest < ActiveSupport::TestCase
  setup do
    @physical_product = PhysicalProduct.new
  end

  test "should have many product_variants" do
    assert_respond_to @physical_product, :product_variants
  end

  test "should have one product" do
    assert_respond_to @physical_product, :product
  end

  test "should accept weight" do
    @physical_product.weight = 1000
    @physical_product.requires_shipping = true
    assert @physical_product.valid?
  end

  test "should accept requires_shipping" do
    @physical_product.weight = 1000
    @physical_product.requires_shipping = true
    assert @physical_product.valid?
  end

  test "should not accept negative weight" do
    @physical_product.weight = -100
    @physical_product.requires_shipping = true
    assert_not @physical_product.valid?
    assert_includes @physical_product.errors[:weight], "must be greater than 0"
  end

  test "should allow nil weight" do
    @physical_product.weight = nil
    @physical_product.requires_shipping = false
    assert @physical_product.valid?
  end

  test "should be valid with no variants" do
    @physical_product.weight = 100
    @physical_product.requires_shipping = true
    assert @physical_product.valid?
  end

  test "should be valid with at least one active variant" do
    @physical_product.weight = 100
    @physical_product.requires_shipping = true
    @product = Product.create!(name: "Test Product", slug: "test-product", price: 10000, state: "active", productable: @physical_product)
    @product.product_variants.create!(name: "Red", price: 100, stock: 10, is_active: true)
    assert @physical_product.valid?
  end

  test "should be invalid with variants but no active ones" do
    @physical_product.weight = 100
    @physical_product.requires_shipping = true
    @product = Product.create!(name: "Test Product", slug: "test-product", price: 10000, state: "active", productable: @physical_product)
    @product.product_variants.create!(name: "Red", price: 100, stock: 10, is_active: false)
    @product.product_variants.create!(name: "Blue", price: 100, stock: 10, is_active: false)
    @physical_product.reload
    assert_not @physical_product.valid?
    assert_includes @physical_product.errors[:product_variants], "must have at least one active variant"
  end

  test "should be valid with active variant present" do
    @physical_product.weight = 100
    @physical_product.requires_shipping = true
    @product = Product.create!(name: "Test Product", slug: "test-product", price: 10000, state: "active", productable: @physical_product)
    @product.product_variants.create!(name: "Red", price: 100, stock: 10, is_active: true)
    @product.product_variants.create!(name: "Blue", price: 100, stock: 10, is_active: false)
    @physical_product.reload
    assert @physical_product.valid?
  end

  test "should be invalid when all variants become inactive" do
    @physical_product.weight = 100
    @physical_product.requires_shipping = true
    @product = Product.create!(name: "Test Product", slug: "test-product", price: 10000, state: "active", productable: @physical_product)
    active_variant = @product.product_variants.create!(name: "Red", price: 100, stock: 10, is_active: true)
    @product.product_variants.create!(name: "Blue", price: 100, stock: 10, is_active: false)

    active_variant.update!(is_active: false)
    @physical_product.reload
    assert_not @physical_product.valid?
    assert_includes @physical_product.errors[:product_variants], "must have at least one active variant"
  end

  test "should access variants through product" do
    @physical_product.weight = 100
    @physical_product.requires_shipping = true
    @product = Product.create!(name: "Test Product", slug: "test-product", price: 10000, state: "active", productable: @physical_product)

    variant1 = @product.product_variants.create!(name: "Red", price: 100, stock: 10, is_active: true)
    variant2 = @product.product_variants.create!(name: "Blue", price: 100, stock: 10, is_active: true)

    assert_equal 2, @physical_product.product_variants.count
    assert_includes @physical_product.product_variants, variant1
    assert_includes @physical_product.product_variants, variant2
  end
end
