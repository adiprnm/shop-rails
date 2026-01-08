require "test_helper"

class PaymentEvidenceTest < ActiveSupport::TestCase
  setup do
    @paid_order = orders(:paid_order)
    @paid_donation = donations(:named_donation)
  end

  test "should be valid with valid attributes" do
    file = File.open(Rails.root.join("test/fixtures/files/test.pdf"))
    evidence = @paid_order.payment_evidences.new(file: file)
    assert evidence.valid?
  end

  test "should belong to payable" do
    assert_respond_to @paid_order.payment_evidences.new, :payable
  end

  test "should have file attached" do
    file = File.open(Rails.root.join("test/fixtures/files/test.pdf"))
    evidence = @paid_order.payment_evidences.create(file: file)
    assert evidence.file.attached?
  end

  test "should allow polymorphic payable" do
    file = File.open(Rails.root.join("test/fixtures/files/test.pdf"))
    order_evidence = @paid_order.payment_evidences.create(file: file)
    donation_evidence = @paid_donation.payment_evidences.create(file: file)

    assert_equal @paid_order, order_evidence.payable
    assert_equal @paid_donation, donation_evidence.payable
  end

  test "should have checked attribute" do
    file = File.open(Rails.root.join("test/fixtures/files/test.pdf"))
    evidence = @paid_order.payment_evidences.create(file: file)
    assert_respond_to evidence, :checked
  end

  test "should default checked to false" do
    file = File.open(Rails.root.join("test/fixtures/files/test.pdf"))
    evidence = @paid_order.payment_evidences.create(file: file)
    assert_not evidence.checked
  end

  test "should allow checked to be true" do
    file = File.open(Rails.root.join("test/fixtures/files/test.pdf"))
    evidence = @paid_order.payment_evidences.create(file: file, checked: true)
    assert evidence.checked
  end

  test "should be ordered by created_at desc by default in association" do
    file = File.open(Rails.root.join("test/fixtures/files/test.pdf"))
    file2 = File.open(Rails.root.join("test/fixtures/files/test.pdf"))
    evidence1 = @paid_order.payment_evidences.create(file: file)
    sleep 0.1
    evidence2 = @paid_order.payment_evidences.create(file: file2)

    assert_equal evidence2.id, @paid_order.payment_evidences.first.id
  end

  test "should update payable to pending when payable is not pending" do
    @paid_order.update(state: "expired")
    file = File.open(Rails.root.join("test/fixtures/files/test.pdf"))
    evidence = @paid_order.payment_evidences.create(file: file)

    assert_equal "pending", @paid_order.reload.state
  end

  test "should not update payable when payable is pending" do
    pending_order = orders(:pending_order)
    pending_order.update(state: "pending")
    file = File.open(Rails.root.join("test/fixtures/files/test.pdf"))
    evidence = pending_order.payment_evidences.create(file: file)

    assert_equal "pending", pending_order.reload.state
  end
end
