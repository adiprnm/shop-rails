class AddEmailAddressToDonations < ActiveRecord::Migration[8.0]
  def change
    add_column :donations, :email_address, :string
  end
end
