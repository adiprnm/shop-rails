import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["provinceSelect", "citySelect", "districtSelect", "subdistrictSelect", "citiesFrame", "districtsFrame", "subdistrictsFrame"]
  static values = { showShipping: Boolean }

  connect() {
    this.updateDependentFields()
  }

  showShippingValueChanged() {
    this.toggleShippingSection()
  }

  toggleShippingSection() {
    const shippingSection = document.querySelector('[data-address-target="shippingSection"]')

    if (shippingSection) {
      if (this.showShippingValue) {
        shippingSection.style.display = 'block'
        shippingSection.style.opacity = '1'
      } else {
        shippingSection.style.opacity = '0'
        setTimeout(() => {
          shippingSection.style.display = 'none'
        }, 300)
      }
    }
  }

  onProvinceChange(event) {
    const provinceId = event.target.value

    this.resetDependentFields("city")
    this.resetDependentFields("district")
    this.resetDependentFields("subdistrict")

    if (provinceId) {
      const url = `/addresses/cities?province_id=${provinceId}`
      this.fetchAndUpdate(url, this.citiesFrameTarget)
      this.enableField(this.citySelectTarget)
    } else {
      this.disableField(this.citySelectTarget)
    }
  }

  onCityChange(event) {
    const cityId = event.target.value

    this.resetDependentFields("district")
    this.resetDependentFields("subdistrict")

    if (cityId) {
      const url = `/addresses/districts?city_id=${cityId}`
      this.fetchAndUpdate(url, this.districtsFrameTarget)
      this.enableField(this.districtSelectTarget)
    } else {
      this.disableField(this.districtSelectTarget)
    }
  }

  onDistrictChange(event) {
    const districtId = event.target.value

    this.resetDependentFields("subdistrict")

    if (districtId) {
      const url = `/addresses/subdistricts?district_id=${districtId}`
      this.fetchAndUpdate(url, this.subdistrictsFrameTarget)
      this.enableField(this.subdistrictSelectTarget)
    } else {
      this.disableField(this.subdistrictSelectTarget)
    }
  }

  onSubdistrictChange(event) {
    const subdistrictId = event.target.value

    if (subdistrictId) {
      this.fetchShippingCosts(subdistrictId)
    }
  }

  updateDependentFields() {
    const hasProvince = this.hasProvinceSelectTarget && this.provinceSelectTarget.value
    const hasCity = this.hasCitySelectTarget && this.citySelectTarget.value
    const hasDistrict = this.hasDistrictSelectTarget && this.districtSelectTarget.value

    if (this.hasCitySelectTarget) {
      if (hasProvince && this.citySelectTarget.options.length > 0) {
        this.enableField(this.citySelectTarget)
      } else {
        this.disableField(this.citySelectTarget)
      }
    }

    if (this.hasDistrictSelectTarget) {
      if (hasCity && this.districtSelectTarget.options.length > 0) {
        this.enableField(this.districtSelectTarget)
      } else {
        this.disableField(this.districtSelectTarget)
      }
    }

    if (this.hasSubdistrictSelectTarget) {
      if (hasDistrict && this.subdistrictSelectTarget.options.length > 0) {
        this.enableField(this.subdistrictSelectTarget)
      } else {
        this.disableField(this.subdistrictSelectTarget)
      }
    }
  }

  enableField(field) {
    field.disabled = false
  }

  disableField(field) {
    field.disabled = true
    field.value = ""
  }

  resetDependentFields(fieldName) {
    const frame = this[`${fieldName}FrameTarget`]
    const select = this[`${fieldName}SelectTarget`]

    if (frame) {
      frame.innerHTML = ""
    }

    if (select) {
      select.innerHTML = '<option value="">Select ' + fieldName + '</option>'
      select.disabled = true
      select.value = ""
    }
  }

  async fetchAndUpdate(url, target) {
    try {
      const response = await fetch(url, {
        headers: {
          "Accept": "text/vnd.turbo-stream.html"
        }
      })

      if (response.ok) {
        const html = await response.text()
        target.innerHTML = html
      }
    } catch (error) {
      console.error("Error fetching address data:", error)
    }
  }

  async fetchShippingCosts(subdistrictId) {
    try {
      const response = await fetch(`/shipping_costs?subdistrict_id=${subdistrictId}`, {
        headers: {
          "Accept": "text/vnd.turbo-stream.html"
        }
      })

      if (response.ok) {
        const html = await response.text()
        Turbo.renderStreamMessage(html)
      }
    } catch (error) {
      console.error("Error fetching shipping costs:", error)
    }
  }
}
