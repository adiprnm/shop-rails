class Admin::SettingsController < ApplicationController
  layout "admin"

  def update
    Setting.bulk_update(settings_params.as_json)

    redirect_to admin_settings_path, notice: "Pengaturan berhasil diupdate!"
  end

  private
    def settings_params
      params.permit(
        :site_name, :payment_client_id, :payment_client_secret, :payment_api_host
      )
    end
end
