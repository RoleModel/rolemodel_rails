const { optimize, extendDefaultPlugins } = require('svgo')

module.exports = function(content) {

  // TODO: We should add some documentation here explaining what this config doing.
  const svgoConfig = {
    multipass: true,
    plugins: extendDefaultPlugins([
      {
        name: 'inlineStyles',
        params: {
          onlyMatchedOnce: false
        }
      },
      'convertStyleToAttrs',
      {
        name: 'removeViewBox',
        active: false
      },
      'removeDimensions'
    ])
  }

  const result = optimize(content, svgoConfig)
  const betterSVG = result.data

  // Check how many colors the icon uses. If the icon has only one color, we can
  // allow it to be recolored via CSS.
  const colorsRegex = /(fill|stroke)="(?!none)(?<color>.*?)"/gi
  const allColors = [...betterSVG.matchAll(colorsRegex)].map(match => match.groups.color)
  const uniqueColors = new Set(allColors)

  if (uniqueColors.size > 1) {
    // The icon uses multiple colors, so overriding its color with CSS won't
    // work. Preserve the colors as-is.
    return betterSVG
  }

  // This icon only uses one color, so allow recoloring it with CSS by setting
  // fill and stroke properties (that are not set to "none") to use CSS
  // currentColor attribute.
  return betterSVG.replace(colorsRegex, '$1="currentColor"')
}
