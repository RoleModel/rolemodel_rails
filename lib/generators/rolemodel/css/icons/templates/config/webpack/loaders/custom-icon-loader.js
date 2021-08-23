const svgColorOverrideLoader = require.resolve('./svg-color-override-loader')

module.exports = function() {}
// Using Webpack's pitch phase use `file-loader` to copy the SVG to the
// output folder and get a URL to load it (used in the Ruby icon helper).
//
// From experimentation, we found that this only worked in the pitch phase.
module.exports.pitch = function(request) {
  // Modify SVG file to export an object with one key: url - a URL to load the SVG from the server
  //
  // Require string syntax:
  // Parts are separated by "!" and executed right to left. The "!!" at the
  // beginning skips other configured loaders (so we don't call this loader with
  // its own output). Query parameters (e.g., "?name=...") can be used to pass
  // options to loaders.
  //
  // So this query will:
  // 1. Skipping other configured loaders,
  // 2. Loading the file source,
  // 3. Running it through our custom `svg-color-loader` to allow recoloring the
  //    icon with CSS
  // 4. Running it through `file-loader` and passing an option so the SVG so it is copied to the
  //    correct place in the output folder.
  return `
    module.exports = {
      url: require('!!file-loader?name=media/images/[folder]/[name]-[hash].[ext]!${svgColorOverrideLoader}!${request}').default
    }
  `
}