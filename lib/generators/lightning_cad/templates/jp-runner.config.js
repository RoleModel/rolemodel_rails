import DetailedTestFormatter from '@rolemodel/jasmine-playwright-runner/src/server/DetailedTestFormatter.js'

export default {
  specPatterns: [
    'spec/javascript/browser/**/*Spec.js',
    'spec/javascript/browser/**/*Spec.jsx',
    'spec/javascript/shared/**/*Spec.js'
  ],
  setupFiles: [
    'spec/javascript/shared/TestSetup.js',
    'spec/javascript/browser/TestSetup.js'
  ],
  formatter: new DetailedTestFormatter()
}
