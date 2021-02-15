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
      bodyElement.innerHTML = '<div class="page-load__error"><span class="material-icons">error</span><p>Uh oh! Something broke. Try reloading...</p></div>'
    })
  })
}

export default makeFormsRemote
