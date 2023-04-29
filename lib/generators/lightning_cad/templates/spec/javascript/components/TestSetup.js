import '@testing-library/jest-dom/extend-expect'
import '@rolemodel/lightning-cad/geometry/index.js'

import '../helpers/initializers.js'
import setupJSDOM from '@rolemodel/lightning-cad/drawing-editor/spec/helpers/setupJSDOM.js'

// Install our mock for Canvas elements
setupJSDOM()

await import('./support/matchMedia.js')
