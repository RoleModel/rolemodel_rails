// import { SmartObjectBuilder } from '@rolemodel/lightning-cad/smartJSON'

// let isWebpackEnvironment
// // If fs can't be required or is stubbed out, we're in a webpack environment.
// // Otherwise, we're in a node/test environment.
// try {
//   const fs = await import('fs')
//   // The glob package uses readdirSync, so that's a good one to check
//   isWebpackEnvironment = typeof fs.readdirSync !== 'function'
// } catch {
//   isWebpackEnvironment = true
// }

// let domainModels = []
// if (isWebpackEnvironment) {
//   // Usually browser
//   domainModels = await import('../../shared/domain-models/**/*.js')
// } else {
//   // Node/test environment
//   const path = await import('path')
//   const glob = await import('glob')
//   const url = await import('url')

//   const __dirname = url.fileURLToPath(new URL('.', import.meta.url))
//   const files = glob.sync('**/*.js', {
//     cwd: path.resolve(path.join(__dirname, '../../shared/domain-models')),
//   })

//   domainModels = []

//   await Promise.all(
//     files.map(async (file) => {
//       domainModels.push(await import(`../../shared/domain-models/${file}`))
//     })
//   )
// }

// SmartObjectBuilder.configure((config) => {
//   config.classes.addClasses(...domainModels)
// })
