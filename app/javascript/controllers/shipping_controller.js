import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["totalDisplay", "shippingOptions", "courierInput", "serviceInput", "costInput"]
  static values = { baseTotal: Number }

  connect() {
    this.updateTotal()
  }

  updateTotal(event) {
    const selectedOption = event.target

    if (selectedOption.checked) {
      const price = parseFloat(selectedOption.dataset.price)
      const courier = selectedOption.dataset.courier
      const service = selectedOption.dataset.service

      this.courierInputTarget.value = courier
      this.serviceInputTarget.value = service
      this.costInputTarget.value = price

      this.updateTotalDisplay(this.baseTotalValue + price)
    }
  }

  updateTotalDisplay(total) {
    const totalElement = this.totalDisplayTarget
    if (totalElement) {
      totalElement.textContent = this.formatCurrency(total)
    }
  }

  formatCurrency(amount) {
    return new Intl.NumberFormat("id-ID", {
      style: "currency",
      currency: "IDR",
      minimumFractionDigits: 0
    }).format(amount)
  }
}
