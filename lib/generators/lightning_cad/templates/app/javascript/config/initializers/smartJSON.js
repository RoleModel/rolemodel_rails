import { SmartObjectBuilder } from '@rolemodel/lightning-cad/smartJSON'

let domainModelModules = []
if (import.meta.webpackContext) {
  const domainModelsContext = await import.meta.webpackContext(
    '../../shared/domain-models',
    {
      recursive: true,
      regExp: /.js$/,
    }
  )
  // Usually browser
  domainModelModules = domainModelsContext.keys().map(domainModelsContext)
} else {
  // Node/test environment
  const path = await import('path')
  const glob = await import('glob')
  const url = await import('url')

  const __dirname = url.fileURLToPath(new URL('.', import.meta.url))
  const files = glob.sync('**/*.js', {
    cwd: path.resolve(path.join(__dirname, '../../shared/domain-models'))
  })

  domainModelModules = []

  await Promise.all(
    files.map(async (file) => {
      domainModelModules.push(await import(`../../shared/domain-models/${file}`))
    })
  )
}

const domainModels = domainModelModules.map(({ default: module }) => module)

SmartObjectBuilder.configure((config) => {
  config.classes.addClasses(...domainModels)
})
