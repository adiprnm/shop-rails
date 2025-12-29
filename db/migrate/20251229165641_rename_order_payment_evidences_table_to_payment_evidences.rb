class RenameOrderPaymentEvidencesTableToPaymentEvidences < ActiveRecord::Migration[8.0]
  def change
    rename_table :order_payment_evidences, :payment_evidences
    add_column :payment_evidences, :payable_id, :biginteger, null: false
    add_column :payment_evidences, :payable_type, :string, null: false
    add_column :payment_evidences, :checked, :boolean, null: false, default: false
    remove_column :orders, :has_unchecked_payment_evidence
    remove_column :donations, :has_unchecked_payment_evidence
  end
end
