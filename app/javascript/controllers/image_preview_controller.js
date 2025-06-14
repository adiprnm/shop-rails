import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="image-preview"
export default class extends Controller {
  static targets = ["preview"]

  perform() {
    const file = event.target.files[0];
    let reader = new FileReader();
    let imagePreviewTarget = this.previewTarget;

    reader.onload = function (event) {
      imagePreviewTarget.hidden = false;
      imagePreviewTarget.setAttribute("src", event.target.result);
    };
    reader.readAsDataURL(file);

  }
}
