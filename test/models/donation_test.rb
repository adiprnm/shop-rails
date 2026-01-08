require "test_helper"

class DonationTest < ActiveSupport::TestCase
  setup do
    @donation = donations(:pending_donation)
    Current.settings = { "payment_provider" => "manual" }
    Current.time_zone = "Asia/Jakarta"
  end

  test "should be valid with valid attributes" do
    assert @donation.valid?
  end

  test "should not be valid without amount" do
    @donation.amount = nil
    assert_not @donation.valid?
  end

  test "should not be valid with amount below minimum" do
    @donation.amount = 1000
    assert_not @donation.valid?
  end

  test "should be valid with minimum amount" do
    @donation.amount = 5000
    assert @donation.valid?
  end

  test "should generate donation_id before create" do
    assert_not_nil @donation.donation_id
  end

  test "should set state_updated_at when state changes" do
    @donation.state = "paid"
    @donation.save
    assert_not_nil @donation.state_updated_at
  end

  test "should have pending state" do
    assert_equal "pending", donations(:pending_donation).state
  end

  test "should have paid state" do
    assert_equal "paid", donations(:named_donation).state
  end

  test "should have expired state" do
    assert_equal "expired", donations(:expired_donation).state
  end

  test "should return latest_payment_evidence" do
    file = File.open(Rails.root.join("test/fixtures/files/test.pdf"))
    @donation.payment_evidences.create(file: file)
    assert_equal @donation.payment_evidences.first, @donation.latest_payment_evidence
  end

  test "should return name or Seseorang if name is blank" do
    assert_equal "Seseorang", donations(:anonymous_donation).name
  end

  test "should return name if name is present" do
    assert_equal "Alice Johnson", donations(:named_donation).name
  end

  test "should be expired if created more than 1 day ago and pending" do
    @donation.update(created_at: 2.days.ago, state: "pending")
    assert @donation.expire?
  end

  test "should not be expired if created less than 1 day ago" do
    @donation.update(created_at: 12.hours.ago, state: "pending")
    assert_not @donation.expire?
  end

  test "should not be expired if not pending" do
    @donation.update(created_at: 2.days.ago, state: "paid")
    assert_not @donation.expire?
  end

  test "should calculate will_expire_at correctly" do
    created_at = @donation.created_at
    expected_expiry = (created_at + 1.day).in_time_zone("Asia/Jakarta")
    assert_equal expected_expiry, @donation.will_expire_at
  end

  test "should mark evidences as checked" do
    file = File.open(Rails.root.join("test/fixtures/files/test.pdf"))
    evidence1 = @donation.payment_evidences.create(file: file, checked: false)
    evidence2 = @donation.payment_evidences.create(file: file, checked: false)

    @donation.mark_evidences_as_checked

    assert evidence1.reload.checked?
    assert evidence2.reload.checked?
  end

  test "should only mark unchecked evidences as checked" do
    file = File.open(Rails.root.join("test/fixtures/files/test.pdf"))
    evidence1 = @donation.payment_evidences.create(file: file, checked: true)
    evidence2 = @donation.payment_evidences.create(file: file, checked: false)

    @donation.mark_evidences_as_checked

    assert evidence1.reload.checked?
    assert evidence2.reload.checked?
  end

  test "should delete payment_evidences when donation is destroyed" do
    file = File.open(Rails.root.join("test/fixtures/files/test.pdf"))
    evidence = @donation.payment_evidences.create(file: file)

    assert_difference("PaymentEvidence.count", -1) do
      @donation.destroy
    end
  end

  test "scope paid should return paid donations" do
    assert_includes Donation.paid, donations(:anonymous_donation)
    assert_includes Donation.paid, donations(:named_donation)
  end

  test "scope paid should not return pending donations" do
    assert_not_includes Donation.paid, donations(:pending_donation)
  end

  test "should allow nil email_address" do
    @donation.email_address = nil
    assert @donation.valid?
  end
end
