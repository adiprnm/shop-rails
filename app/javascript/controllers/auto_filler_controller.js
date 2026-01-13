import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="auto-filler"
export default class extends Controller {
  static values = { fields: Array }

  connect() {
    const element = this.element

    this.fieldsValue.forEach((name) => {
      const value = localStorage.getItem(name)
      const field = element.querySelector(`[name="${name}"]`)
      if (field && value) {
        field.value = value
      }
    })

    this.checkCartType()
  }

  save({ target }) {
    const key =  target.name
    const value = target.value
    localStorage.setItem(key, value)
  }

  clearAddressFields() {
    const addressFields = ["address_line", "shipping_province_id", "shipping_city_id", "shipping_district_id", "shipping_subdistrict_id"]

    addressFields.forEach((fieldName) => {
      localStorage.removeItem(fieldName)
      const field = this.element.querySelector(`[name="${fieldName}"]`)
      if (field) {
        field.value = ""
      }
    })
  }

  checkCartType() {
    const hasPhysicalProduct = this.hasPhysicalProductsInCart()

    if (!hasPhysicalProduct) {
      this.clearAddressFields()
    }
  }

  hasPhysicalProductsInCart() {
    const cartData = document.querySelector('[data-has-physical-products]')
    return cartData && cartData.dataset.hasPhysicalProducts === "true"
  }
}
