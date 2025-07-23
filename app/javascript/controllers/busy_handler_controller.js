import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="busy-handler"
export default class extends Controller {
  handle(event) {
    event.preventDefault()
    event.target.setAttribute('aria-busy', true)
    event.target.disabled = true

    if (this.element.tagName.toLowerCase() === 'form') {
      this.element.requestSubmit()
    }
  }
}
