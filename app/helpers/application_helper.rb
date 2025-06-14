module ApplicationHelper
  def idr(amount)
    return "Gratis" if amount.zero?

    number_to_currency(amount, unit: "Rp", separator: ".", delimiter: ".", precision: 0)
  end
end
