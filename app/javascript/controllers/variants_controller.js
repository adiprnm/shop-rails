import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["variant", "destroyInput"]
  static values = { index: Number }

  connect() {
    this.indexValue = this.variantTargets.length
  }

  add() {
    const template = document.createElement("template")
    template.innerHTML = `
      <div class="variant-form mb-4" data-variants-target="variant">
        <div class="form-group">
          <label for="product_productable_attributes_product_variants_attributes_${this.indexValue}_name">Name</label>
          <input type="text" name="product[productable_attributes][product_variants_attributes][${this.indexValue}][name]" id="product_productable_attributes_product_variants_attributes_${this.indexValue}_name">
        </div>
        <div class="form-group">
          <label for="product_productable_attributes_product_variants_attributes_${this.indexValue}_price">Price</label>
          <input type="number" step="0.01" min="0" name="product[productable_attributes][product_variants_attributes][${this.indexValue}][price]" id="product_productable_attributes_product_variants_attributes_${this.indexValue}_price">
        </div>
        <div class="form-group">
          <label for="product_productable_attributes_product_variants_attributes_${this.indexValue}_weight">Weight (override, grams)</label>
          <input type="number" step="1" min="0" name="product[productable_attributes][product_variants_attributes][${this.indexValue}][weight]" id="product_productable_attributes_product_variants_attributes_${this.indexValue}_weight">
        </div>
        <div class="form-group">
          <label for="product_productable_attributes_product_variants_attributes_${this.indexValue}_stock">Stock</label>
          <input type="number" step="1" min="0" name="product[productable_attributes][product_variants_attributes][${this.indexValue}][stock]" id="product_productable_attributes_product_variants_attributes_${this.indexValue}_stock">
        </div>
        <div class="form-group check-boxes">
          <input type="checkbox" value="1" name="product[productable_attributes][product_variants_attributes][${this.indexValue}][is_active]" id="product_productable_attributes_product_variants_attributes_${this.indexValue}_is_active">
          <label for="product_productable_attributes_product_variants_attributes_${this.indexValue}_is_active">Is active</label>
        </div>
        <input type="hidden" value="0" name="product[productable_attributes][product_variants_attributes][${this.indexValue}][_destroy]" id="product_productable_attributes_product_variants_attributes_${this.indexValue}__destroy" data-variants-target="destroyInput">
        <button type="button" data-action="click->variants#remove" class="btn btn-danger">Remove</button>
      </div>
    `
    this.element.insertAdjacentElement("beforeend", template.content.firstElementChild)
    this.indexValue++
  }

  remove(event) {
    event.preventDefault()
    const variantElement = event.target.closest("[data-variants-target='variant']")

    if (variantElement.querySelector('input[type="hidden"]')) {
      const destroyInput = variantElement.querySelector("[data-variants-target='destroyInput']")
      destroyInput.value = "1"
      variantElement.style.display = "none"
    } else {
      variantElement.remove()
    }
  }
}
