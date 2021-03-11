import RolemodelPanel from 'helpers/rolemodel-panel'
import RolemodelModal from 'helpers/rolemodel-modal'
import RolemodelConfirm from 'helpers/rolemodel-confirm'

document.addEventListener('turbolinks:load', () => {
  RolemodelPanel.init()
  RolemodelModal.init()
  RolemodelConfirm.init()
})
