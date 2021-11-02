import loadingErrorTemplate from './loadingErrorTemplate'

const makeFormsRemote = (bodyElement, containerId) => {
  document.getElementById(containerId).querySelectorAll('form').forEach((element) => {
    element.setAttribute('data-remote', 'true')

    element.addEventListener('ajax:success', (event) => {
      const request = event.detail[2]

      if (request.getResponseHeader('location')) { return }

      bodyElement.innerHTML = event.detail[0].body.innerHTML
      makeFormsRemote(bodyElement, containerId)
    })

    element.addEventListener('ajax:error', (_event) => {
      bodyElement.innerHTML = loadingErrorTemplate
    })
  })
}

export default makeFormsRemote
