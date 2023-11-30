import { Controller } from '@hotwired/stimulus'
import React from 'react'
import { createRoot } from 'react-dom/client'

import App from '../components/App.jsx'

const registeredComponents = {
  App,
}

export default class extends Controller {
  connect() {
    const componentName = this.element.dataset.component
    const Component = registeredComponents[componentName]

    if (Component) {
      const root = createRoot(this.element)
      const props = JSON.parse(this.element.dataset.props)
      root.render(React.createElement(component, props))
    } else {
      throw new Error('Unrecognized React component name!')
    }
  }
}
