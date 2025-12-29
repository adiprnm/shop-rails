class AddHasUncheckedPaymentEvidenceToOrder < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :has_unchecked_payment_evidence, :boolean, default: false
  end
end
