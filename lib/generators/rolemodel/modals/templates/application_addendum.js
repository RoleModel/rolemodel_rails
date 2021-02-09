import RolemodelPanel from './rolemodel-panel'
import RolemodelModal from './rolemodel-modal'
import RolemodelCustomConfirm from './rolemodel-custom-confirm'

document.addEventListener('turbolinks:load', () => {
  RolemodelPanel.init()
  RolemodelModal.init()
  RolemodelCustomConfirm.init()
}
