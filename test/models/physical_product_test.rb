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

  test "should accept nested attributes for product_variants" do
    assert_respond_to @physical_product, :product_variants_attributes=
  end

  test "should be valid with at least one active variant" do
    @physical_product.weight = 100
    @physical_product.requires_shipping = true
    @physical_product.product_variants.build(name: "Red", price: 100, stock: 10, is_active: true)
    assert @physical_product.valid?
  end

  test "should be invalid with variants but no active ones" do
    @physical_product.weight = 100
    @physical_product.requires_shipping = true
    @physical_product.product_variants.build(name: "Red", price: 100, stock: 10, is_active: false)
    @physical_product.product_variants.build(name: "Blue", price: 100, stock: 10, is_active: false)
    assert_not @physical_product.valid?
    assert_includes @physical_product.errors[:product_variants], "must have at least one active variant"
  end

  test "should be valid when only marked for destruction variants are inactive" do
    @physical_product.weight = 100
    @physical_product.requires_shipping = true
    variant = @physical_product.product_variants.build(name: "Red", price: 100, stock: 10, is_active: false)
    variant.mark_for_destruction
    @physical_product.product_variants.build(name: "Blue", price: 100, stock: 10, is_active: true)
    assert @physical_product.valid?
  end

  test "should be invalid with mix of active and inactive variants when only inactive remain after destruction" do
    @physical_product.weight = 100
    @physical_product.requires_shipping = true
    active_variant = @physical_product.product_variants.build(name: "Red", price: 100, stock: 10, is_active: true)
    @physical_product.product_variants.build(name: "Blue", price: 100, stock: 10, is_active: false)
    active_variant.mark_for_destruction
    assert_not @physical_product.valid?
    assert_includes @physical_product.errors[:product_variants], "must have at least one active variant"
  end

  test "should allow creating variants via nested attributes" do
    @physical_product.weight = 100
    @physical_product.requires_shipping = true
    assert_difference "@physical_product.product_variants.count", 2 do
      @physical_product.update(
        product_variants_attributes: [
          { name: "Red", price: 100, stock: 10, is_active: true },
          { name: "Blue", price: 100, stock: 10, is_active: true }
        ]
      )
    end
  end

  test "should allow destroying variants via nested attributes" do
    @physical_product.weight = 100
    @physical_product.requires_shipping = true
    variant = @physical_product.product_variants.create!(name: "Red", price: 100, stock: 10, is_active: true)
    assert_difference "@physical_product.product_variants.count", -1 do
      @physical_product.update(product_variants_attributes: [ { id: variant.id, _destroy: "1" } ])
    end
  end

  test "should allow destroying variants via nested attributes when other active variants exist" do
    @physical_product.weight = 100
    @physical_product.requires_shipping = true
    active_variant = @physical_product.product_variants.create!(name: "Red", price: 100, stock: 10, is_active: true)
    @physical_product.product_variants.create!(name: "Blue", price: 100, stock: 10, is_active: true)
    assert_difference "@physical_product.product_variants.count", -1 do
      @physical_product.update(product_variants_attributes: [ { id: active_variant.id, _destroy: "1" } ])
    end
  end
end
