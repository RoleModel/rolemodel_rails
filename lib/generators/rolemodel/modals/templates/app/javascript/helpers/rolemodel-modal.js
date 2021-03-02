import makeFormsRemote from './makeFormsRemote'
import loadingErrorTemplate from './loadingErrorTemplate'

export default class RolemodelModal {
  static init() {
    const rolemodelModal = new RolemodelModal()
    rolemodelModal.enableModalOpen()
    rolemodelModal.enableModalClose()
  }

  get modal() {
    return document.getElementById('modal')
  }

  get modalBody() {
    return document.getElementById('modal-body')
  }

  get closeModalElement() {
    return document.getElementById('modal-close')
  }

  enableModalOpen() {
    document.querySelectorAll('a[data-modal]').forEach((element) => {
      element.addEventListener('ajax:send', (e) => {
        this.modal.classList.add('modal--active')
      })

      element.addEventListener('ajax:success', (e) => {
        this.modalBody.innerHTML = e.detail[0].body.innerHTML
        makeFormsRemote(this.modalBody, 'modal')
      })

      element.addEventListener('ajax:error', (e) => {
        this.displayError()
      })
    })
  }

  // Prevent trying to attach an event listener when the page doesn't have the modal.
  // For example login, etc
  enableModalClose() {
    if (this.closeModalElement) {
      this.closeModalElement.addEventListener('click', (e) => {
        e.preventDefault()
        this.modal.classList.remove('modal--active')
        setTimeout(() => { this.modalBody.innerHTML = ''}, this.timeoutMilliseconds) // just wait until the animation finishes
      })
    }
  }

  get timeoutMilliseconds() {
    return parseInt(window.getComputedStyle(document.body).getPropertyValue('--modal-transition-speed')) || 1000
  }

  displayError() {
    this.modalBody.innerHTML = loadingErrorTemplate
  }
}
