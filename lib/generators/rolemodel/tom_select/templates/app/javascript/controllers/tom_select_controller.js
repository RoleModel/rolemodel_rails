import { Controller } from '@hotwired/stimulus'
import TomSelect from 'tom-select'

export default class extends Controller {
  static targets = ['dropdown']

  connect() {
    this.tomSelect = new TomSelect(this.dropdownTarget, this.baseSettings)
    this.element.tomSelect = this.tomSelect
  }

  disconnect() {
    // In case a Turbo morph is happening, we need to update TomSelect's revertSettings,
    // in order to preserve the current value(s) when reconnecting.
    this.tomSelect.revertSettings.innerHTML = this.element.innerHTML

    this.tomSelect.destroy()
    delete this.element.tomSelect
  }

  afterMorph() {
    queueMicrotask(() => this.connect())
  }

  get baseSettings() {
    return {
      create: false,
      persist: false,
      maxOptions: null,
      maxItems: this.dropdownTarget.multiple ? null : 1,
      plugins: this.dropdownTarget.multiple ? ['remove_button', 'dropdown_input'] : ['dropdown_input'],
    }
  }
}
