import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ["modal"]

  open() {
    this.modalTarget.showModal()
  }

  close() {
    this.modalTarget.close()
  }
}
