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

  content = File.read(Rails.root.join("app/page_contents/terms.md"))
  Page.published.create_with(
    title: "Syarat dan Ketentuan",
    slug: "syarat-dan-ketentuan",
    description: "Syarat dan ketentuan toko online #{ Setting.site_name.value }",
    content: content
  ).find_or_create_by(slug: "syarat-dan-ketentuan")

  content = File.read(Rails.root.join("app/page_contents/refund_policies.md"))
  Page.published.create_with(
    title: "Kebijakan Pengembalian Dana (Refund Policy)",
    slug: "kebijakan-pengembalian-dana",
    description: "Kebijakan pengembalian dana toko online #{ Setting.site_name.value }",
    content: content
  ).find_or_create_by(slug: "kebijakan-pengembalian-dana")

  puts "Admin credentials has been successfully set up. You can configure the other credentials at the /admin page"
end
