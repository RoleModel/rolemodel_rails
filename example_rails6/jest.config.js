module.exports = {
  roots: [
    'app/javascript',
    'spec/javascript/components'
  ],
  testRegex: '\\Spec\\.(js|jsx)$',
  testURL: 'http://localhost',
  modulePaths: [
    '<rootDir>/app/javascript'
  ],
  moduleNameMapper: {
    "\\.(jpg|jpeg|png|gif|eot|otf|webp|ttf|woff|woff2|mp4|webm|wav|mp3|m4a|aac|oga|svg)$": "<rootDir>/spec/javascript/support/FilePathMock.js"
  },
}
