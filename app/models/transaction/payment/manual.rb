class Transaction::Payment::Manual
  attr_reader :payable

  def initialize(payable)
    @payable = payable
  end

  def redirect_url
    if payable.is_a?(Order)
      Rails.application.routes.url_helpers.order_url(payable.order_id, only_path: true)
    elsif payable.is_a?(Donation)
      Rails.application.routes.url_helpers.support_url(payable.donation_id, only_path: true)
    end
  end
end
