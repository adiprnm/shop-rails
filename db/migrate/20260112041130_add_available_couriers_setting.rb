class AddAvailableCouriersSetting < ActiveRecord::Migration[8.0]
  def change
    up_only do
      Setting.available_couriers.update value: "jne,tiki,pos"
    end
  end
end
