const { optimize, extendDefaultPlugins } = require('svgo')

module.exports = function(content) {

  // Normalize SVGs to make them resize properly and allow overriding colors.
  // This also applies other optimizations to SVGs which are not strictly
  // necessary but can reduce file size.
  const svgoConfig = {
    // Make sure these options are fully applied (sometimes multiple passes are required)
    multipass: true,
    plugins: extendDefaultPlugins([
      // 1. Convert <style> elements to inline styles on individual SVG
      //    elements. <style> elements are not scoped to the SVG, so this
      //    prevents conflicting styles between icons (or non-SVG elements).
      {
        name: 'inlineStyles',
        params: {
          // By default, CSS selectors in a <style> element that match multiple
          // elements in the SVG are not inlined.
          onlyMatchedOnce: false
        }
      },
      // 2. Convert inline styles to style attributes (<path fill="black"/>
      //    instead of <path style="fill: black;" />) so we can more easily
      //    replace stroke/fill colors. This works with the previous step to
      //    move global CSS rules to style attributes.
      'convertStyleToAttrs',
      // 3. Normalize the SVG's overall view box and dimensions so resizing the
      //    icon will work properly.
      {
        // This plugin is in the default set, but we need the viewbox attribute
        // for proper resizing behavior.
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

  if (uniqueColors.size === 0) {
    // If colors are not specified, the defaults are:
    //   1. stroke="none" (https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke#usage_notes)
    //   2. fill="black" for shapes and text (https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/fill#circle)
    //      Note that `fill` has a different meaning for animation-related
    //      elements, which should not be present in icons.
    //
    // Set "fill" for the entire SVG to the CSS currentColor attribute so the
    // icon can be recolored.
    return betterSVG.replace(/(<svg )/i, '$1fill="currentColor" ')
  }

  // This icon only uses one color, so allow recoloring it with CSS by setting
  // fill and stroke properties (that are not set to "none") to use CSS
  // currentColor attribute.
  return betterSVG.replace(colorsRegex, '$1="currentColor"')
}
