import path from 'node:path'
import * as glob from 'glob'
import filterFile from '../../../config/webpack/loaders/filter-file.js'

const shorthandRoot = path.join(process.cwd(), 'app/javascript')
const config = {
  shorthandRoot
}

export function resolve(specifier, context, nextResolve) {
  let finalSpecifier = specifier
  if (specifier.startsWith('#')) {
    finalSpecifier = resolveShorthandPath(finalSpecifier, context, nextResolve)
  }

  if (specifier.includes('*')) {
    return resolveGlobPath(finalSpecifier, context, nextResolve)
  }

  return nextResolve(finalSpecifier, context)
}

export async function load(specifier, context, nextLoad) {
  if (!specifier.includes('*')) {
    const result = await nextLoad(specifier, context)
    if (!result.source) return result

    const source = filterFile(result.source, 'server')

    return {
      ...result,
      source
    }
  }

  const pattern = specifier.replace('file://', '')
  const paths = glob.globSync(pattern, { nodir: true })

  const pathParts = pattern.split('/')
  const basePathParts = pathParts.slice(0, pathParts.findIndex(part => part.includes('*')))
  // we need to determine how many times we have a "*" in a folder level. The imports have to go back that far in order to work properly.
  const folderLevels = pathParts.length - basePathParts.length - 1 // minus one for the file
  const basePath = basePathParts.join('/')
  const baseImportPath = `${Array(folderLevels).fill('../').join('')}`

  const getModuleIdentifier = index => `module${index}`
  const getImportPath = file => path.join(baseImportPath, path.relative(basePath, file))
  const importStatements = paths.map((file, index) => {
    return `import * as ${getModuleIdentifier(index)} from './${getImportPath(file)}'`
  })
  const exportStatement = `export default [${paths.map((_s, index) => getModuleIdentifier(index)).join(', ') }]`

  const content = [...importStatements, exportStatement].join('\n')
  const source = Buffer.from(content)

  return {
    format: "module",
    source,
    shortCircuit: true
  }
}

function resolveShorthandPath(specifier, _context, _nextResolve) {
  return path.join(config.shorthandRoot, specifier.slice(1))
}

function resolveGlobPath(specifier, context, _nextResolve) {
  // We have to manually resolve the path so that we can load all the files that match the pattern later
  let finalPath
  if (specifier.startsWith('.')) { // Relative path to parent
    const basePath = context.parentURL.replace('file://', '').split('/').slice(0, -1).join('/')
    finalPath = path.join(basePath, specifier)
  } else if (specifier.startsWith('/')) { // Absolute path
    finalPath = specifier
  } else { // node modules
    finalPath = path.join(process.cwd(), 'node_modules', specifier)
  }

  return {
    url: `file://${finalPath}`,
    type: "module",
    shortCircuit: true
  }
}
