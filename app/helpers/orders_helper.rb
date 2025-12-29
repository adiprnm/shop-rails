module OrdersHelper
  def order_status_tag(order)
    css_class = "badge__order-#{ order.state }"
    tag.span order.state.titleize, class: "badge #{ css_class }"
  end
end
