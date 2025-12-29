class AddHasUncheckedPaymentEvidenceToDonation < ActiveRecord::Migration[8.0]
  def change
    add_column :donations, :has_unchecked_payment_evidence, :boolean, default: false
  end
end
