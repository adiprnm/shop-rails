import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "shippingOptions", "finalTotalDisplay"]
  static values = { baseTotal: Number }

  connect() {
    this.updateFinalTotalDisplay(this.baseTotalValue)
  }

  updateTotal(event) {
    const selectedOption = event.target

    if (selectedOption.checked) {
      const price = parseFloat(selectedOption.dataset.price)

      this.updateTotalDisplay(this.baseTotalValue + price)
      this.updateFinalTotalDisplay(this.baseTotalValue + price)
    }
  }

  updateFinalTotalDisplay(total) {
    const finalTotalElement = this.finalTotalDisplayTarget
    if (finalTotalElement) {
      finalTotalElement.textContent = this.formatCurrency(total)
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
