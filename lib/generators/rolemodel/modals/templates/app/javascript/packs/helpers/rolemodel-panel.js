import makeFormsRemote from './makeFormsRemote'
import loadingErrorTemplate from './loadingErrorTemplate'

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
        setTimeout(() => { this.panelContent.innerHTML = '' }, this.timeoutMilliseconds) // just wait until the animation finishes
      })
    }
  }

  get timeoutMilliseconds() {
    return parseInt(window.getComputedStyle(document.body).getPropertyValue('--panel-transition-speed')) || 1000
  }

  displayPanelError() {
    this.panelContent.innerHTML = loadingErrorTemplate
  }
}
