import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "image"]

  open(event) {
    const src = event.currentTarget.getAttribute('src')
    if (!src) return
    this.imageTarget.setAttribute('src', src)
    this.overlayTarget.hidden = false
    document.documentElement.style.overflow = 'hidden'
  }

  close() {
    this.overlayTarget.hidden = true
    this.imageTarget.removeAttribute('src')
    document.documentElement.style.overflow = ''
  }
}

