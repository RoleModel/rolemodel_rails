import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    attributeName: String
  }

  /**
   * Use this method in conjunction with the turbo:before-morph-attribute event to prevent morphing of a specific
   * attribute on an element. This is useful for attributes that may change due to user interaction, such as the "open"
   * attribute on a details element, which can be toggled by the user and should not be overridden by Turbo's morphing process.
   *
   * Example:
   *   <details controller="morph" data-morph-attribute-name-value="open" data-action="turbo:before-morph-attribute->morph#skipMorphAttribute">
   *
   * @param {import("@hotwired/turbo").TurboBeforeMorphAttributeEvent} event
   */
  skipMorphAttribute(event) {
    if (event.detail.attributeName === this.attributeNameValue) {
      event.preventDefault()
    }
  }
}
