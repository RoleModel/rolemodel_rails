import React from 'react'
import { createBrowserHistory } from 'history'
import PropTypes from 'prop-types'

import {
  Icon,
  IconFactoryContext,
  MultiPerspectiveProjectEditorView,
} from '@rolemodel/lightning-cad-ui'
import { Router } from 'react-router-dom'
import LocalIconFactory from './LocalIconFactory.jsx'

import {
  DrawingEditor,
  VersionedProject,
  Project
} from '@rolemodel/lightning-cad/drawing-editor'

export default class App extends React.Component {
  static propTypes = {
    basePath: PropTypes.string,
    backPath: PropTypes.string
  }

  static defaultProps = {
    basePath: '/',
    backPath: '/'
  }

  constructor(props) {
    super(props)
    this._modalRoot = document.getElementById('modal_root') || document.createElement('div')

    this._project = new VersionedProject(new Project())

    const top = new DrawingEditor(this._project)
    top.toolPalette()
    this._drawingEditors = { top }
  }

  modalRoot() { return this._modalRoot }

  history() {
    if (!this._history) {
      this._history = createBrowserHistory({ basename: this.props.basePath })
    }
    return this._history
  }

  iconFactory() {
    return this._iconFactory ??= new LocalIconFactory()
  }

  render() {
    return (
      <IconFactoryContext.Provider value={this.iconFactory()}>
        <Router history={this.history()}>
          <MultiPerspectiveProjectEditorView
            drawingEditors={this._drawingEditors}
            versionedProject={this._project}
            perspectiveOptions={{
              top: {
                actionBarOptions: {
                  includePerspectiveIcons: false,
                  renderBackLink: (_drawingEditor) => (
                    <a
                      href={this.props.backPath}
                      title='Back'
                      className='action-bar__back margin-right-md'
                    >
                      <Icon
                        name='KeyboardArrowLeft'
                        className='action-bar__icon'
                      />
                      Back
                    </a>
                  ),
                },
              },
            }}
          />
        </Router>
      </IconFactoryContext.Provider>
    )
  }
}
