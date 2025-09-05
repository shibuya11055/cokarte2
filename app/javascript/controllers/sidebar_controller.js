import { Controller } from "@hotwired/stimulus"

// Controls the off-canvas sidebar on small screens with accessibility
export default class extends Controller {
  static targets = ["panel", "overlay", "toggle"]

  connect() {
    // Key handling
    this._onKeydown = (e) => {
      if (e.key === 'Escape') this.close()
    }
    document.addEventListener('keydown', this._onKeydown)

    // Close on navigation
    this._onBeforeVisit = () => this.close()
    document.addEventListener('turbo:before-visit', this._onBeforeVisit)

    // Ensure correct ARIA state on load
    this._syncAria()
  }

  disconnect() {
    document.removeEventListener('keydown', this._onKeydown)
    document.removeEventListener('turbo:before-visit', this._onBeforeVisit)
  }

  toggle() {
    if (document.body.classList.contains('side-menu-open')) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    document.body.classList.add('side-menu-open')
    // lock scroll
    document.documentElement.style.overflow = 'hidden'
    document.body.style.overflow = 'hidden'
    this._syncAria(true)
  }

  close() {
    document.body.classList.remove('side-menu-open')
    // unlock scroll
    document.documentElement.style.overflow = ''
    document.body.style.overflow = ''
    this._syncAria(false)
  }

  _syncAria(open = document.body.classList.contains('side-menu-open')) {
    if (this.hasToggleTarget) this.toggleTarget.setAttribute('aria-expanded', open ? 'true' : 'false')
    if (this.hasPanelTarget) this.panelTarget.setAttribute('aria-hidden', open ? 'false' : 'true')
    if (this.hasOverlayTarget) this.overlayTarget.setAttribute('aria-hidden', open ? 'false' : 'true')
  }
}
