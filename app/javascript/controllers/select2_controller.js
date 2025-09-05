import { Controller } from "@hotwired/stimulus"

// Initialize Select2 on a <select> element, robust to Turbo navigation
export default class extends Controller {
  static values = {
    placeholder: { type: String, default: '選択してください' },
    width: { type: String, default: '100%' }
  }

  connect() {
    this._mounted = false
    this._beforeCache = () => this.teardown()
    document.addEventListener('turbo:before-cache', this._beforeCache)
    this._tryMount()
  }

  disconnect() {
    document.removeEventListener('turbo:before-cache', this._beforeCache)
    this.teardown()
  }

  _tryMount(attempt = 0) {
    // Ensure jQuery and select2 plugin are available
    if (window.jQuery && window.jQuery.fn && typeof window.jQuery.fn.select2 === 'function') {
      this.mount()
      return
    }
    // retry a few times in case CDN script hasn't loaded yet
    if (attempt < 20) {
      setTimeout(() => this._tryMount(attempt + 1), 50)
    }
  }

  mount() {
    if (this._mounted) return
    const $ = window.jQuery
    const el = this.element
    if (!el) return

    // Avoid double init
    if ($(el).hasClass('select2-hidden-accessible')) {
      try { $(el).select2('destroy') } catch (_) {}
    }

    $(el).select2({
      width: this.widthValue,
      placeholder: this.placeholderValue,
      allowClear: true,
      language: { noResults: () => '該当なし' }
    })
    this._mounted = true
  }

  teardown() {
    if (!this._mounted) return
    const $ = window.jQuery
    if ($ && this.element) {
      try { $(this.element).select2('destroy') } catch (_) {}
    }
    this._mounted = false
  }
}

