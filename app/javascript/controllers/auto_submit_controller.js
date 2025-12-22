import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="auto-submit"
export default class extends Controller {
  perform() {
    this.element.requestSubmit()
  }
}
