import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="copy-text"
export default class extends Controller {
  static targets = ["modal"]

  perform({ target }) {
    navigator.clipboard.writeText(target.dataset.accountNumber);
    this.modalTarget.showModal()
  }

  closeModal() {
    this.modalTarget.close();
  }
}
