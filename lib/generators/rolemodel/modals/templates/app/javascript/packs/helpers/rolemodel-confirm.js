const Rails = require("@rails/ujs")

export default class RolemodelConfirm {
  static init() {
    const rolemodelConfirm = new RolemodelConfirm()
    rolemodelConfirm.enableConfirmOpen()
    rolemodelConfirm.enableConfirmClose()
  }

  get confirmModal() {
    return document.getElementById('confirm')
  }

  get confirmTitle() {
    return document.getElementById('confirm-title')
  }

  get confirmBody() {
    return document.getElementById('confirm-body')
  }

  get confirmAccept() {
    return document.getElementById('confirm-accept')
  }

  get closeModalElement() {
    return document.getElementById('confirm-close')
  }

  // This pattern was pulled from: https://derk-jan.com/2020/10/rails-ujs-custom-confirm/
  // Rails allows the override of the confirm to add in custom confirms
  // See https://git.io/Jtg5e
  enableConfirmOpen() {
    let _skipConfirmation = false

    Rails.confirm = (message, element) => {
      // JavaScript is single threaded. We can temporarily change this variable
      // in order to skip out of the confirmation logic.
      //
      // When this function returns true, the event (such as a click event) that
      // sourced it is not prevented from executing whatever it was supposed to
      // trigger, such as a form submission, or following a link.
      if (_skipConfirmation) { return true }


      // Additional data attributes can be added on the element and pulled in
      // here. For example if you want change the "Cancel" button text to
      // something else, you could have a data-confirm-cancel="No way!" and
      // then set it on this.closeModalElement
      const data = element.dataset
      this.confirmTitle.innerText = message
      if (data.confirmDetails) {
        this.confirmBody.innerText = data.confirmDetails
      }
      if (data.confirmButton) {
        this.confirmAccept.innerText = data.confirmButton
      }

      // This function should be executed when the dialog's positive action is
      // clicked. All it does is re-click the element that was originally
      // triggering this confirmation.
      //
      // Clicking that element will, as expected, re-call Rails.confirm but
      // because _skipConfirmation is set, it will bail out early.
      this.confirmAccept.addEventListener('click', (e) => {
        e.preventDefault()
        _skipConfirmation = true
        element.click()
        _skipConfirmation = false
      })

      // Open the modal
      this.confirmModal.classList.add('modal--active')

      // Rails.confirm expects a true or false return. False here prevents the
      // action in question (deleting something, etc.) from happening right away
      return false
    }
  }

  // Prevent trying to attach an event listener when the page doesn't have the modal.
  // For example login, client login, etc
  enableConfirmClose() {
    if (this.closeModalElement) {
      this.closeModalElement.addEventListener('click', (e) => {
        e.preventDefault()
        this.confirmModal.classList.remove('modal--active')
      })
    }
  }
}
