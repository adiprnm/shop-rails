module ApplicationHelper
  def idr(amount, text: true)
    return "-" if amount.nil?
    return "Gratis" if amount.zero? && text

    number_to_currency(amount, unit: "Rp", separator: ".", delimiter: ".", precision: 0)
  end

  def icon(name, options)
    file = Nokogiri::XML.parse Rails.root.join("app/assets/images/heroicons/#{name}.svg")
    if options[:class].present?
      file.at_css("svg").add_class(options[:class])
    end
    file.to_html.html_safe
  end

  def font_files
    Dir.glob(Rails.root.join("public/fonts/*.ttf")).to_a.tap do |files|
      files.map! { |file| "/fonts/#{ File.basename(file) }" }
    end
  end

  def go_to_top_button(id)
    link_to "##{id}", class: "go-to-top", role: "button" do
      icon "arrow-up", class: "icon"
    end
  end
end
