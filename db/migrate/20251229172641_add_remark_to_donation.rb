class AddRemarkToDonation < ActiveRecord::Migration[8.0]
  def change
    add_column :donations, :remark, :string
  end
end
