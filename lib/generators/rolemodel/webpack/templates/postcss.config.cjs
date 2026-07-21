module.exports = {
  syntax: require('postcss-scss'),
  plugins: [
    require('postcss-preset-env')({
      autoprefixer: {
        flexbox: 'no-2009'
      },
      stage: 3
    })
  ]
}
