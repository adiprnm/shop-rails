import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas"]

  static values = {
    chartData: { type: Object }
  }

  connect() {
    this.renderChart()
  }

  renderChart() {
    if (!this.chartDataValue || !this.hasCanvasTarget) return

    const ctx = this.canvasTarget.getContext('2d')
    const data = this.chartDataValue

    new Chart(ctx, {
      type: 'line',
      data: {
        labels: data.dates,
        datasets: data.coupons.map((code, index) => ({
          label: code,
          data: data.data[index],
          borderColor: this.getRandomColor(index),
          backgroundColor: this.getRandomColor(index, 0.1),
          tension: 0.4,
          fill: false
        }))
      },
      options: {
        responsive: true,
        maintainAspectRatio: true,
        plugins: {
          legend: {
            display: true,
            position: 'bottom'
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            title: {
              display: true,
              text: 'Jumlah Penggunaan'
            }
          },
          x: {
            title: {
              display: true,
              text: 'Tanggal'
            }
          }
        }
      }
    })
  }

  getRandomColor(index, alpha = 1) {
    const colors = [
      `rgba(59, 130, 246, ${alpha})`,
      `rgba(234, 172, 53, ${alpha})`,
      `rgba(148, 49, 38, ${alpha})`,
      `rgba(234, 172, 53, ${alpha})`,
      `rgba(148, 49, 38, ${alpha})`,
      `rgba(59, 130, 246, ${alpha})`
    ]
    return colors[index % colors.length]
  }
}
