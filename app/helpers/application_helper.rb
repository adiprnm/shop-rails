module ApplicationHelper
  def idr(amount)
    return "Gratis" if amount.zero?

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
    Dir.glob(Rails.root.join("app/assets/fonts/*.ttf")).to_a.tap do |files|
      files.map! { |file| file.split("/").last }
    end
  end
end
