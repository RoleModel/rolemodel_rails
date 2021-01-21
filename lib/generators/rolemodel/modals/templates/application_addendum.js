
import 'turbolinks-animate';

document.addEventListener('turbolinks:load', () => {
  TurbolinksAnimate.init()

  const panel = document.getElementById('panel')
  const panelContent = document.getElementById('panel-content')

  document.querySelectorAll('a[data-panel]').forEach((element) => {

    element.addEventListener('ajax:send', (e) => {
      panel.classList.add('panel--active')
    })

    element.addEventListener('ajax:success', (e) => {
      panelContent.innerHTML = e.detail[0].body.innerHTML
      makeFormsRemote(panelContent, 'panel')
    })

    element.addEventListener('ajax:error', (e) => {
      displayPanelError(panelContent)
    })
  })

  const closePanelElement = document.getElementById('panel-close')

  if (closePanelElement) {
    closePanelElement.addEventListener('click', () => {
      panel.classList.remove('panel--active')
      setTimeout(() => { panelContent.innerHTML = '' }, 1000) // just wait until the animation finishes (400ms)
    })
  }
})

const makeFormsRemote = (bodyElement, containerId) => {
  document.getElementById(containerId).querySelectorAll('form').forEach((element) => {
    element.setAttribute('data-remote', 'true')

    element.addEventListener('ajax:success', (e) => {
      const xhrRequest = e.detail[2]

      if (xhrRequest.getResponseHeader('location')) { return }

      bodyElement.innerHTML = e.detail[0].body.innerHTML
      makeFormsRemote(bodyElement, containerId)
    })

    element.addEventListener('ajax:error', (e) => {
      displayPanelError(bodyElement)
    })
  })
}

const displayPanelError = (bodyElement) => {
  bodyElement.innerHTML = '<div class="panel__error"><span class="material-icons">error</span><p>Uh oh! Something broke. Try reloading...</p></div>'
}

// modals
document.addEventListener('turbolinks:load', () => {
  const customConfirm = document.getElementById('custom-confirm')
  const customConfirmTitle = document.getElementById('custom-confirm-title')
  const customConfirmBody = document.getElementById('custom-confirm-body')
  const customConfirmForm = document.getElementById('custom-confirm-form')
  const closeModalElement = document.getElementById('custom-confirm-close')

  // basic customConfirm
  document.querySelectorAll('a[data-custom-confirm]').forEach((element) => {
    element.addEventListener('click', (e) => {
      e.preventDefault()
      e.stopPropagation()

      const customConfirmData = element.dataset
      customConfirmTitle.innerText = customConfirmData.confirmTitle
      customConfirmBody.innerText = customConfirmData.confirmBody
      customConfirmForm.action = element.getAttribute('href')
      const input = document.createElement('input');
      input.setAttribute('type', 'hidden');
      input.setAttribute('name', '_method');
      input.setAttribute('value', customConfirmData.confirmFormMethod);
      const authToken = customConfirmForm.querySelector('[name="authenticity_token"]')
      if (authToken) { authToken.setAttribute('value', Rails.csrfToken()) }

      customConfirmForm.appendChild(input);

      customConfirm.classList.add('modal--active')
    })
  })

  // Prevent trying to attach an event listener when the page doesn't have the modal.
  // For example login, client login, etc
  if (closeModalElement) {
    closeModalElement.addEventListener('click', (e) => {
      e.preventDefault()
      customConfirm.classList.remove('modal--active')
    })
  }
})

// remote modal
document.addEventListener('turbolinks:load', () => {
  const modal = document.getElementById('modal')
  const modalBody = document.getElementById('modal-body')
  const closeModalElement = document.getElementById('modal-close')
  document.querySelectorAll('a[data-custom-remote-modal]').forEach((element) => {
    element.addEventListener('ajax:send', (e) => {
      modal.classList.add('modal--active')
    })

    element.addEventListener('ajax:success', (e) => {
      modalBody.innerHTML = e.detail[0].body.innerHTML
      makeFormsRemote(modalBody, 'modal')
    })

    element.addEventListener('ajax:error', (e) => {
      displayPanelError(modalBody)
    })
  })

  // Prevent trying to attach an event listener when the page doesn't have the modal.
  // For example login, client login, etc
  if (closeModalElement) {
    closeModalElement.addEventListener('click', (e) => {
      e.preventDefault()
      modal.classList.remove('modal--active')
    })
  }
})
