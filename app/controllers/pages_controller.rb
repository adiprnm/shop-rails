class PagesController < ApplicationController
  def terms_and_conditions
    @title = "Syarat dan Ketentuan"
    @description = "Syarat dan ketentuan toko online #{ Current.settings["site_name"] }."
    @content = File.read(Rails.root.join("app/page_contents/terms.md"))
    render "pages/show", locals: { content: @content }
  end
end
