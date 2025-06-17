class SetupInitialSettingValues < ActiveRecord::Migration[8.0]
  def change
    up_only do
      Setting.site_name.update value: "Store"
      Setting.site_favicon.update value: "🛒"
      Setting.site_main_menu.update value: "[Home](/)"
    end
  end
end
