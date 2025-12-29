class CreateOrderPaymentEvidences < ActiveRecord::Migration[8.0]
  def change
    create_table :order_payment_evidences do |t|
      t.references :order, null: false, foreign_key: true

      t.timestamps
    end
  end
end
