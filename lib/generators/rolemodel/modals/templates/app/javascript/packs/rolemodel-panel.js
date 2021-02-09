import makeFormsRemote from './makeFormsRemote'

export default class RolemodelPanel {
  static init() {
    const rolemodelPanel = new RolemodelPanel()
    rolemodelPanel.enablePanelOpen()
    rolemodelPanel.enablePanelClose()
  }

  get panel() {
    return document.getElementById('panel')
  }

  get panelContent() {
    return document.getElementById('panel-content')
  }

  get closePanelElement() {
    return document.getElementById('panel-close')
  }

  enablePanelOpen() {
    document.querySelectorAll('a[data-panel]').forEach((element) => {

      element.addEventListener('ajax:send', (e) => {
        this.panel.classList.add('panel--active')
      })

      element.addEventListener('ajax:success', (e) => {
        this.panelContent.innerHTML = e.detail[0].body.innerHTML
        makeFormsRemote(this.panelContent, 'panel')
      })

      element.addEventListener('ajax:error', (e) => {
        this.displayPanelError()
      })
    })
  }

  enablePanelClose() {
    if (this.closePanelElement) {
      this.closePanelElement.addEventListener('click', () => {
        this.panel.classList.remove('panel--active')
        setTimeout(() => { this.panelContent.innerHTML = '' }, 1000) // just wait until the animation finishes (400ms)
      })
    }
  }

  displayPanelError() {
    this.panelContent.innerHTML = '<div class="page-load__error"><span class="material-icons">error</span><p>Uh oh! Something broke. Try reloading...</p></div>'
  }
}
