process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')

// This will cause source maps to be generated and a sourceMappingURL
// will be appended to the bundled JS
environment.config.devtool = 'source-map'

// Relocate source maps out of /public/packs/js after compilation completes.
const RelocateSourceMapsPlugin = require('./plugins/RelocateSourceMapsPlugin')
environment.plugins.append('RelocateSourceMaps', new RelocateSourceMapsPlugin())

module.exports = environment.toWebpackConfig()
