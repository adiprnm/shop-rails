module OrdersHelper
  def status_tag(payable)
    css_class = "badge__status-#{ payable.state }"
    tag.span payable.state.titleize, class: "badge #{ css_class }"
  end
end
