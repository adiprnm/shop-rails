class Admin::SettingsController < AdminController
  def update
    Setting.bulk_update(settings_params)

    redirect_to admin_settings_path, notice: "Pengaturan berhasil diupdate!"
  end

  private
    def settings_params
      params.permit(*Setting::KEYS)
    end
end
