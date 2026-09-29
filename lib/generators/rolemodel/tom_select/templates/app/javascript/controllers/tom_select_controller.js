import { Controller } from '@hotwired/stimulus'
import TomSelect from 'tom-select'

export default class extends Controller {
  static values = { create: Boolean }

  connect() {
    this.tomSelect = new TomSelect(this.element, this.settings)
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

  get settings() {
    return {
      create: this.createValue,
      persist: false,
      maxOptions: null,
      delimiter: null,
      maxItems: this.element.multiple ? null : 1,
      plugins: this.element.multiple ? ['remove_button'] : [],
      onItemAdd: () => this.tomSelect.setTextboxValue(''), // clear the input text box when a selection is made
    }
  }
}
