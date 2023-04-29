export default {
  roots: ["app/javascript", "spec/javascript/components"],
  testRegex: "\\Spec\\.(js|jsx)$",
  testEnvironmentOptions: {
    url: "http://localhost",
  },
  transformIgnorePatterns: ["/node_modules(?!\/\@rolemodel\/lightning-cad)/"],
  setupFilesAfterEnv: ["./spec/javascript/components/TestSetup.js"],
  modulePaths: ["<rootDir>/app/javascript"],
  setupFilesAfterEnv: ["./spec/javascript/components/TestSetup.js"],
  moduleNameMapper: {
    "\\.svg$":
      "<rootDir>/node_modules/@rolemodel/lightning-cad/drawing-editor-react/__tests__/mocks/svgMock.js",
    "\\.(jpg|jpeg|png|gif|eot|otf|webp|ttf|woff|woff2|mp4|webm|wav|mp3|m4a|aac|oga)$":
      "<rootDir>/spec/javascript/support/FilePathMock.js",
  },
};
