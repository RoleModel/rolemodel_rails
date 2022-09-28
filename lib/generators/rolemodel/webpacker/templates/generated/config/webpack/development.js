process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')

// This will cause source maps to be generated and a file:/// sourceMappingURL
// will be appended to the bundled JS
environment.config.devtool = false
const { SourceMapDevToolPlugin } = require('webpack')
environment.plugins.prepend(
  'SourceMapDevToolPlugin',
  new SourceMapDevToolPlugin({
    append: "\n//# sourceMappingURL=[url]",
    filename: "[file].map"
  })
)

// Relocate source maps out of /public/packs/js after compilation completes.
const RelocateSourceMapsPlugin = require('./plugins/RelocateSourceMapsPlugin')
environment.plugins.append('RelocateSourceMaps', new RelocateSourceMapsPlugin())

module.exports = environment.toWebpackConfig()
