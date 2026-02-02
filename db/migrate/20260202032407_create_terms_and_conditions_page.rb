class CreateTermsAndConditionsPage < ActiveRecord::Migration[8.0]
  def up
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
  end

  def down
    Page.where(slug: [ "syarat-dan-ketentuan", "kebijakan-pengembalian-dana" ]).delete_all
  end
end
