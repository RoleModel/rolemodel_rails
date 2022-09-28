const fs = require('fs')
const path = require('path')

class RelocateSourceMapsPlugin {
  constructor(mapsDirectory = 'maps') {
    this._mapsDirectory = mapsDirectory
  }

  mapsDirectory() {
    return this._mapsDirectory
  }

  apply(compiler) {
    compiler.hooks.done.tap(this.constructor.name, this.done.bind(this))
  }

  _ensurePath(directory) {
    try {
      const stats = fs.statSync(directory)

      if (!stats.isDirectory()) {
        console.log(`WARNING: ${directory} exists but is not a directory`)
      }

      return
    } catch (error) {
      if (error.code !== 'ENOENT') throw error
    }

    fs.mkdirSync(directory)
  }

  _moveFiles(sourceDirectory, files) {
    if (!files) return

    const destinationDirectory = this.mapsDirectory()
    this._ensurePath(destinationDirectory)

    files.forEach(file => {
      const sourcePath = path.join(sourceDirectory, file)
      const destinationPath = path.join(destinationDirectory, file)

      fs.renameSync(sourcePath, destinationPath)

      console.log(`${sourcePath} was relocated to ${destinationDirectory}`)
    })
  }

  done(stats) {
    const outputPath = stats.compilation.outputOptions.path
    const jsPath = path.join(outputPath, 'js')
    fs.readdir(jsPath, undefined, (error, files) => {
      if (error) throw error

      const mapFiles = files.filter(file => file.match('js.map'))
      this._moveFiles(jsPath, mapFiles)
    })
  }
}

module.exports = RelocateSourceMapsPlugin
