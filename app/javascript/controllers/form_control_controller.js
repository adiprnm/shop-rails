import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form-control"
export default class extends Controller {
  static values = { requiredFields: Array, model: String }
  static targets = [ "submitButton" ]

  perform() {
    let element;

    this.submitButtonTarget.disabled = !this.requiredFieldsValue.every(field => {
      if (this.hasModelValue) {
        element = this.element.querySelector(`input[id="${this.modelValue}_${field}"]`)
      } else {
        element = this.element.querySelector(`input[name="${field}"]`)
      }

      let match = element.value.trim().length > 0
      const min = parseInt(element.min)
      if (Number.isInteger(min)) {
        match &&= parseInt(element.value) >= min
      }
      return match
    })
  }
}
