import React from "react"
import ReactDOM from 'react-dom'

let reactDOMRoot

export function setup() {
  window.React = React
  window.ReactDOM = ReactDOM

  afterEach(() => {
    if (reactDOMRoot) {
      ReactDOM.unmountComponentAtNode(reactDOMRoot)
      reactDOMRoot.remove()
      reactDOMRoot = undefined
    }
  })
}

export function render(reactNode) {
  if (!reactDOMRoot) {
    reactDOMRoot = document.createElement('div')
    document.body.append(reactDOMRoot)
  }

  ReactDOM.render(reactNode, reactDOMRoot)
}
