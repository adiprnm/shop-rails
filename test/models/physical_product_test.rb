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
end
