class Transaction::Payment
  def self.for(payable)
    case Current.settings["payment_provider"]
    when "midtrans" then Midtrans.new(payable)
    when "manual" then Manual.new(payable)
    else raise "Unsupported payment provider!"
    end
  end
end
