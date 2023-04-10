import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['element']
  static classes = ['active']
  static values = {
    performOnConnect: {
      type: Boolean,
      default: false,
    }
  }

  connect() {
    if (this.performOnConnectValue) this.perform()
  }

  perform() {
    if (this.hasElementTarget) {
      this.elementTargets.forEach(this._toggleActiveClass)
    } else {
      this._toggleActiveClass(this.element)
    }
  }

  _toggleActiveClass(element) {
    // next-tick to allow animation-in after connect
    setTimeout(()=>{element.classList.toggle(this.activeClass)}, 0)
  }
}
