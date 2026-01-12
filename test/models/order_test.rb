require "test_helper"

class OrderTest < ActiveSupport::TestCase
  setup do
    @order = orders(:pending_order)
    Current.settings = { "payment_provider" => "manual" }
    Current.time_zone = "Asia/Jakarta"
  end

  test "should be valid with valid attributes" do
    assert @order.valid?
  end

  test "should not be valid without customer_agree_to_terms" do
    @order.customer_agree_to_terms = false
    assert_not @order.valid?
  end

  test "should generate order_id before create" do
    assert_not_nil @order.order_id
  end

  test "should set state_updated_at when state changes" do
    @order.state = "paid"
    @order.save
    assert_not_nil @order.state_updated_at
  end

  test "should belong to cart" do
    assert_respond_to @order, :cart
  end

  test "should have many line items" do
    assert_respond_to @order, :line_items
  end

  test "should have many payment_evidences" do
    assert_respond_to @order, :payment_evidences
  end

  test "should have pending state" do
    assert_equal "pending", orders(:pending_order).state
  end

  test "should have paid state" do
    assert_equal "paid", orders(:paid_order).state
  end

  test "should have expired state" do
    assert_equal "expired", orders(:expired_order).state
  end

  test "should return latest_payment_evidence" do
    @order.payment_evidences.create(file: File.open(Rails.root.join("test/fixtures/files/test.pdf")), checked: false)
    assert_equal @order.payment_evidences.first, @order.latest_payment_evidence
  end

  test "should be expired if created more than 1 day ago and pending" do
    @order.update(created_at: 2.days.ago, state: "pending")
    assert @order.expire?
  end

  test "should not be expired if created less than 1 day ago" do
    @order.update(created_at: 12.hours.ago, state: "pending")
    assert_not @order.expire?
  end

  test "should not be expired if not pending" do
    @order.update(created_at: 2.days.ago, state: "paid")
    assert_not @order.expire?
  end

  test "should calculate will_expire_at correctly" do
    created_at = @order.created_at
    expected_expiry = (created_at + 1.day).in_time_zone("Asia/Jakarta")
    assert_equal expected_expiry, @order.will_expire_at
  end

  test "should mark evidences as checked" do
    evidence1 = @order.payment_evidences.create(file: File.open(Rails.root.join("test/fixtures/files/test.pdf")), checked: false)
    evidence2 = @order.payment_evidences.create(file: File.open(Rails.root.join("test/fixtures/files/test.pdf")), checked: false)

    @order.mark_evidences_as_checked

    assert evidence1.reload.checked?
    assert evidence2.reload.checked?
  end

  test "should only mark unchecked evidences as checked" do
    evidence1 = @order.payment_evidences.create(file: File.open(Rails.root.join("test/fixtures/files/test.pdf")), checked: true)
    evidence2 = @order.payment_evidences.create(file: File.open(Rails.root.join("test/fixtures/files/test.pdf")), checked: false)

    @order.mark_evidences_as_checked

    assert evidence1.reload.checked?
    assert evidence2.reload.checked?
  end

  test "should delete line items when order is destroyed" do
    line_item = @order.line_items.first

    assert_difference("OrderLineItem.count", -1) do
      @order.destroy
    end
  end

  test "should delete payment_evidences when order is destroyed" do
    evidence = @order.payment_evidences.create(file: File.open(Rails.root.join("test/fixtures/files/test.pdf")))

    assert_difference("PaymentEvidence.count", -1) do
      @order.destroy
    end
  end

  test "scope today should return orders created today" do
    @order.update(state_updated_at: Time.now)
    assert_includes Order.today, @order
  end

  test "scope today should not return orders created yesterday" do
    @order.update(state_updated_at: 1.day.ago)
    assert_not_includes Order.today, @order
  end

  test "should set tracking_number_updated_at when tracking_number changes" do
    @order.update(tracking_number: "JP123456789")
    assert_not_nil @order.tracking_number_updated_at
  end

  test "should allow tracking_number to be optional" do
    @order.update(tracking_number: nil)
    assert @order.valid?
  end

  test "should allow tracking_number when present" do
    @order.update(tracking_number: "JP123456789")
    assert @order.valid?
  end

  test "should update tracking_number_updated_at when tracking_number is updated" do
    @order.update(tracking_number: "JP123456789")
    original_updated_at = @order.tracking_number_updated_at

    sleep(0.01)
    @order.update(tracking_number: "JP987654321")

    assert @order.tracking_number_updated_at > original_updated_at
  end
end
