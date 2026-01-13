import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="copy-text"
export default class extends Controller {
  static targets = ["modal"]

  perform({ target }) {
    const value = target.dataset.accountNumber || target.dataset.amount
    navigator.clipboard.writeText(value);
    this.modalTarget.showModal()
  }

  closeModal() {
    this.modalTarget.close();
  }
}
