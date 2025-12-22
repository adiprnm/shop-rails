require_relative "../config/environment"

# Your code goes here
if Setting.admin_username.value.present? || Setting.admin_password.value.present?
  puts "Admin user have been set up."
else
  puts "Admin username:"
  username = gets.chomp
  puts "Admin password:"
  password = gets.chomp
  puts "Admin email:"
  email = gets.chomp
  puts "Site name:"
  site_name = gets.chomp

  Setting.admin_username.update value: username
  Setting.admin_password.update value: password
  Setting.admin_email.update value: email
  Setting.site_name.update value: site_name
  Setting.site_main_menu.update value: "[Home](/)"
  Setting.site_storage_host.update value: ENV["STORAGE_HOST"]
  Setting.site_terms_and_conditions_url.update value: "/syarat-dan-ketentuan"

  puts "Admin credentials has been successfully set up. You can configure the other credentials at the /admin page"
end
