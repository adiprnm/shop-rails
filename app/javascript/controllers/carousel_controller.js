import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "slide", "prev", "next"]
  static values = { currentIndex: 0, autoplay: { type: Boolean, default: false }, interval: { type: Number, default: 5000 } }

  connect() {
    this.showSlide(0);

    if (this.autoplayValue) {
      this.startAutoplay();
    }

    this.element.addEventListener("keydown", this.handleKeydown.bind(this));
  }

  disconnect() {
    this.stopAutoplay();
    this.element.removeEventListener("keydown", this.handleKeydown.bind(this));
  }

  next() {
    this.currentIndexValue = (this.currentIndexValue + 1) % this.slideTargets.length;
    this.showSlide(this.currentIndexValue);
  }

  previous() {
    this.currentIndexValue = (this.currentIndexValue - 1 + this.slideTargets.length) % this.slideTargets.length;
    this.showSlide(this.currentIndexValue);
  }

  goTo({ target }) {
    const index = parseInt(target.dataset.index)
    console.log(index)
    this.currentIndexValue = index;
    this.showSlide(index);
  }

  showSlide(index) {
    this.slideTargets.forEach((slide, i) => {
      slide.classList.remove("active");
      slide.hidden = i !== index;

      if (i === index) {
        setTimeout(() => {
          slide.classList.add("active");
        }, 10);
      }
    });

    this.updateIndicators(index);

    if (this.hasPrevTarget) {
      this.prevTarget.disabled = this.slideTargets.length <= 1;
    }

    if (this.hasNextTarget) {
      this.nextTarget.disabled = this.slideTargets.length <= 1;
    }
  }

  updateIndicators(index) {
    const indicators = this.element.querySelectorAll(".carousel-indicator");
    indicators.forEach((indicator, i) => {
      indicator.classList.toggle("active", i === index);
    });
  }

  handleKeydown(event) {
    if (event.key === "ArrowLeft") {
      this.previous();
    } else if (event.key === "ArrowRight") {
      this.next();
    }
  }

  startAutoplay() {
    this.interval = setInterval(() => this.next(), this.intervalValue);
  }

  stopAutoplay() {
    if (this.interval) {
      clearInterval(this.interval);
    }
  }
}
