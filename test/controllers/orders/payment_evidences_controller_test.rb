require "test_helper"

class Orders::PaymentEvidencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @order = orders(:pending_order)
  end

  test "should get new" do
    get new_order_payment_evidence_path(@order.order_id)
    assert_response :success
  end

  test "should assign order" do
    get new_order_payment_evidence_path(@order.order_id)
    assert_equal @order, assigns(:order)
  end

  test "should assign new payment_evidence" do
    get new_order_payment_evidence_path(@order.order_id)
    assert assigns(:payment_evidence).new_record?
  end

  test "should create payment evidence" do
    assert_difference("PaymentEvidence.count") do
      post order_payment_evidence_path(@order.order_id), params: {
        payment_evidence: {
          file: fixture_file_upload("test.pdf", "application/pdf")
        }
      }
    end
  end

  test "should redirect to order after creating payment evidence" do
    post order_payment_evidence_path(@order.order_id), params: {
      payment_evidence: {
        file: fixture_file_upload("test.pdf", "application/pdf")
      }
    }

    assert_redirected_to order_path(@order.order_id)
  end

  test "should attach payment evidence to order" do
    post order_payment_evidence_path(@order.order_id), params: {
      payment_evidence: {
        file: fixture_file_upload("test.pdf", "application/pdf")
      }
    }

    assert_equal @order, PaymentEvidence.last.payable
  end

  test "should not create payment evidence without file" do
    assert_no_difference("PaymentEvidence.count") do
      post order_payment_evidence_path(@order.order_id), params: {
        payment_evidence: {}
      }
    end
  end
end
