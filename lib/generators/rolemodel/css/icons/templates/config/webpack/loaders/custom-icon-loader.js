const svgColorOverrideLoader = require.resolve('./svg-color-override-loader')

module.exports = function() {}
// Using Webpack's pitch phase lets us replace SVG files with a source that will
// load the SVG twice: first using `raw-loader` to get the SVG as a string (used
// directly from JS code) and then using `file-loader` to copy the SVG to the
// output folder and get a URL to load it (used in the Ruby icon helper).
//
// From experimentation, we found that this only worked in the pitch phase.
module.exports.pitch = function(request) {
  // Modify SVG file to export an object with two keys:
  // 1. source - the SVG as a string
  // 2. url - a URL to load the SVG from the server
  //
  // Require string syntax:
  // Parts are separated by "!" and executed right to left. The "!!" at the
  // beginning skips other configured loaders (so we don't call this loader with
  // its own output). Query parameters (e.g., "?name=...") can be used to pass
  // options to loaders.
  //
  // So these two requires are:
  // 1. Skipping other configured loaders,
  // 2. Loading the file source,
  // 3. Running it through our custom `svg-color-loader` to allow recoloring the
  //    icon with CSS
  // 4. Running it through either `raw-loader` or `file-loader`. In the case of
  //    file loader, we are passing an option so the SVG is copied to the
  //    correct place in the output folder.
  return `
    module.exports = {
      source: require('!!raw-loader!${svgColorOverrideLoader}!${request}').default,
      url: require('!!file-loader?name=media/[folder]/[name]-[hash].[ext]!${svgColorOverrideLoader}!${request}').default
    }
  `
}