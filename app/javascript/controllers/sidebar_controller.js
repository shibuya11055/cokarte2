import { Controller } from "@hotwired/stimulus"

// Controls the off-canvas sidebar on small screens
export default class extends Controller {
  static targets = ["overlay"]

  connect() {
    // Close on escape key
    this._onKeydown = (e) => {
      if (e.key === 'Escape') this.close()
    }
    document.addEventListener('keydown', this._onKeydown)
  }

  disconnect() {
    document.removeEventListener('keydown', this._onKeydown)
  }

  toggle() {
    document.body.classList.toggle('side-menu-open')
  }

  open() {
    document.body.classList.add('side-menu-open')
  }

  close() {
    document.body.classList.remove('side-menu-open')
  }
}

