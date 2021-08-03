// Temp fix for turbo and react. Should be update in later version of react-rails
// See https://github.com/reactjs/react-rails/issues/1103 for details
ReactRailsUJS.handleEvent('turbo:load', ReactRailsUJS.handleMount);
ReactRailsUJS.handleEvent('turbo:before-render', ReactRailsUJS.handleUnmount);
