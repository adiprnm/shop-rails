import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="auto-filler"
export default class extends Controller {
  static values = { fields: Array }

  connect() {
    const element = this.element

    this.fieldsValue.forEach((name) => {
      const value = localStorage.getItem(name)
      const field = element.querySelector(`[name="${name}"]`)
      field.value = value
    })
  }

  save({ target }) {
    const key =  target.name
    const value = target.value
    localStorage.setItem(key, value)
  }
}
