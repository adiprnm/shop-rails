require_relative "../config/environment"

# Your code goes here
if Setting.admin_username.value.present? || Setting.admin_password.value.present?
  puts "Admin user have been set up."
else
  puts "Admin username:"
  username = gets.chomp
  puts "Admin password:"
  password = gets.chomp

  Setting.admin_username.update value: username
  Setting.admin_password.update value: password

  puts "Admin credentials has been successfully set up"
end
