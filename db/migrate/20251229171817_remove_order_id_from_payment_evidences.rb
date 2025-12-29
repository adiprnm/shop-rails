class RemoveOrderIdFromPaymentEvidences < ActiveRecord::Migration[8.0]
  def change
    remove_column :payment_evidences, :order_id
  end
end
