class AddIncludedShippingServicesSetting < ActiveRecord::Migration[8.0]
  def change
    up_only do
      Setting.included_shipping_services.update value: ""
    end
  end
end
