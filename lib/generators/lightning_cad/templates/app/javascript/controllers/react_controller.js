import { Controller } from '@hotwired/stimulus'
import React from 'react'
import ReactDOM from 'react-dom'
import App from '../components/App.jsx'

const registeredComponents = {
  App,
}

export default class extends Controller {
  connect() {
    const componentName = this.element.dataset.component
    const Component = registeredComponents[componentName]

    if (Component) {
      const props = JSON.parse(this.element.dataset.props)
      ReactDOM.render(React.createElement(Component, props), this.element)
    } else {
      throw new Error('Unrecognized React component name!')
    }
  }
}
