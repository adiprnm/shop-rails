import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["provinceSelect", "citySelect", "districtSelect", "subdistrictSelect"]

  connect() {
    this.updateCities()
  }

  onProvinceChange() {
    this.updateCities()
    this.updateDistricts()
    this.updateSubdistricts()
  }

  onCityChange() {
    this.updateDistricts()
    this.updateSubdistricts()
  }

  onDistrictChange() {
    this.updateSubdistricts()
  }

  updateCities() {
    const provinceId = this.provinceSelectTarget.value
    const citySelect = this.citySelectTarget

    citySelect.innerHTML = '<option value="">Pilih Kota/Kabupaten</option>'

    if (provinceId) {
      fetch(`/admin/provinces/${provinceId}/cities`)
        .then(response => response.text())
        .then(html => {
          const parser = new DOMParser()
          const doc = parser.parseFromString(html, 'text/html')
          const options = doc.querySelectorAll('option')

          options.forEach(option => {
            if (option.value) {
              citySelect.appendChild(option)
            }
          })
        })
    }

    citySelect.disabled = !provinceId
  }

  updateDistricts() {
    const cityId = this.citySelectTarget.value
    const districtSelect = this.districtSelectTarget

    districtSelect.innerHTML = '<option value="">Pilih Kecamatan</option>'

    if (cityId) {
      fetch(`/admin/cities/${cityId}/districts`)
        .then(response => response.text())
        .then(html => {
          const parser = new DOMParser()
          const doc = parser.parseFromString(html, 'text/html')
          const options = doc.querySelectorAll('option')

          options.forEach(option => {
            if (option.value) {
              districtSelect.appendChild(option)
            }
          })
        })
    }

    districtSelect.disabled = !cityId
  }

  updateSubdistricts() {
    const districtId = this.districtSelectTarget.value
    const subdistrictSelect = this.subdistrictSelectTarget

    subdistrictSelect.innerHTML = '<option value="">Pilih Kelurahan</option>'

    if (districtId) {
      fetch(`/admin/districts/${districtId}/subdistricts`)
        .then(response => response.text())
        .then(html => {
          const parser = new DOMParser()
          const doc = parser.parseFromString(html, 'text/html')
          const options = doc.querySelectorAll('option')

          options.forEach(option => {
            if (option.value) {
              subdistrictSelect.appendChild(option)
            }
          })
        })
    }

    subdistrictSelect.disabled = !districtId
  }
}
