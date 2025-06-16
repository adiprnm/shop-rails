module ProductsHelper
  def render_markdown_as_html(markdown_text)
    markdown = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(hard_wrap: true),
      strikethrough: true,
      fenced_code_blocks: true,
      footnotes: true,
    )
    markdown.render(markdown_text).html_safe
  end
end
