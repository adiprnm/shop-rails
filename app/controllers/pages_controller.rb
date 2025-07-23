class PagesController < ApplicationController
  def terms_and_conditions
    @content = File.read(Rails.root.join("app/page_contents/terms.md"))
    render "pages/show", locals: { content: @content }
  end
end
