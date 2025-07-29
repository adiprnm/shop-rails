import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form-control"
export default class extends Controller {
  static values = { requiredFields: Array }
  static targets = [ "submitButton" ]

  perform() {
    this.submitButtonTarget.disabled = !this.requiredFieldsValue.every(field => {
      const element = this.element.querySelector(`input[name="${field}"]`)

      let match = element.value.trim().length > 0
      const min = parseInt(element.min)
      if (Number.isInteger(min)) {
        match &&= parseInt(element.value) >= min
      }
      return match
    })
  }
}
