import fs from 'fs'
import path from 'path'
import * as url from 'url'
const __dirname = url.fileURLToPath(new URL(".", import.meta.url))

const absoluteBasePath = path.resolve(
  path.join(__dirname, '../../../app/javascript/config/initializers')
)

const files = fs.readdirSync(absoluteBasePath)

await Promise.all(
  files.map(async (file) => {
    if (file.endsWith('.js')) {
      await import(path.join(absoluteBasePath, file))
    }
  })
)
