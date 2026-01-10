require "test_helper"

class OrderLineItemTest < ActiveSupport::TestCase
  setup do
    @order_item = order_line_items(:ruby_guide_order_item)
  end

  test "should belong to order" do
    assert_respond_to @order_item, :order
  end

  test "should belong to orderable" do
    assert_respond_to @order_item, :orderable
  end

  test "should belong to productable" do
    assert_respond_to @order_item, :productable
  end

  test "should belong to product_variant" do
    assert_respond_to @order_item, :product_variant
  end

  test "should have weight attribute" do
    assert_respond_to @order_item, :weight
  end

  test "digital_product? should return true for digital products" do
    assert @order_item.digital_product?
  end

  test "digital_product? should return false for physical products" do
    t_shirt_item = order_line_items(:t_shirt_order_item)
    assert_not t_shirt_item.digital_product?
  end

  test "physical_product? should return true for physical products" do
    t_shirt_item = order_line_items(:t_shirt_order_item)
    assert t_shirt_item.physical_product?
  end

  test "physical_product? should return false for digital products" do
    assert_not @order_item.physical_product?
  end

  test "physical product order item should have product_variant" do
    t_shirt_item = order_line_items(:t_shirt_order_item)
    assert_not_nil t_shirt_item.product_variant
    assert_equal "Red - Small", t_shirt_item.product_variant.name
  end

  test "physical product order item should have weight" do
    t_shirt_item = order_line_items(:t_shirt_order_item)
    assert_equal 250, t_shirt_item.weight
  end
end
