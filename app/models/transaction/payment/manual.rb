class Transaction::Payment::Manual
  attr_reader :payable

  def initialize(payable)
    @payable = payable
  end

  def redirect_url
    id = payable.is_a?(Order) ? payable.order_id : payable.donation_id

    Rails.application.routes.url_helpers.order_url(id, only_path: true)
  end
end
