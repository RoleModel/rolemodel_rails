import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    attributeName: String
  }

  /**
   * Use this method to prevent morphing of a specific attribute on specific elements. This is useful for attributes that may have changed due to user interaction
   * NOTE: The "open" attribute is preserved by default in 'app/javascript/initializers/before_morph_handler.js' and does not require this controller to be used.
   *
   * Example:
   *   <details controller="prevent-morph" data-prevent-morph-attribute-name-value="open" data-action="turbo:before-morph-attribute->prevent-morph#onNamedAttribute">
   *
   * @param {import("@hotwired/turbo").TurboBeforeMorphAttributeEvent} event
   */
  onNamedAttribute(event) {
    if (event.detail.attributeName === this.attributeNameValue) {
      event.preventDefault()
    }
  }
}
