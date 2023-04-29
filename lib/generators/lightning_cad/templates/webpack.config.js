import path from 'path'
import webpack from 'webpack'
import TerserPlugin from 'terser-webpack-plugin'
import HoneybadgerSourceMapPlugin from '@honeybadger-io/webpack'
import MiniCssExtractPlugin from 'mini-css-extract-plugin'
import RemoveEmptyScriptsPlugin from 'webpack-remove-empty-scripts'
import CssMinimizerPlugin from 'css-minimizer-webpack-plugin'

let mode = 'development'

if (process.env.RAILS_ENV === 'production' || process.env.CI === 'true') {
  mode = 'production'
}

export default {
  mode,
  devtool: 'source-map',
  entry: {
    application: [
      './app/javascript/application.js',
      './app/assets/stylesheets/application.scss',
    ],
  },
  experiments: {
    asyncWebAssembly: true,
    topLevelAwait: true,
  },
  output: {
    filename: '[name].js',
    sourceMapFilename: '[file].map',
    path: path.resolve('app/assets/builds'),
  },
  resolve: {
    modules: ['node_modules'],
    extensions: ['.js', '.jsx'],
    alias: {
      // lightning-cad uses 'require' to pull in THREE, but three-bvh-csg uses 'import'.
      // Because THREE's package.json has an exports field with different files for
      // import and require, without this alias THREE was being added to the bundle twice.
      // Not only is that a size problem, but the custom extensions lightning-cad adds to
      // CJS version of THREE aren't picked up because the ESM version of THREE appears first
      // in the bundle and THREE has a check to prevent THREE from being instantiated twice.
      //
      'three/examples': path.resolve('node_modules/three/examples'),
      // TODO: Once lightning-cad migrates to using 'import' to bring in THREE, this alias can be removed.
      three: path.resolve('node_modules/three/build/three.module.js'),

      // LCAD uses `require` to bring in mathjs, but airfield_designer uses `import`, so there are
      // two mathjs module instances in play, and without this line both end up in the final bundle.
      // TODO: Once LCAD migrates to ES Modules, this line can be removed.
      mathjs: path.resolve('node_modules/mathjs/lib/esm'),

      // Webpack apparently doesn't support the * in package.imports, so we need to duplicate
      // package.imports here for webpack.
      '#components': path.resolve('app/javascript/components'),
      '#shared': path.resolve('app/javascript/shared'),
      '#three': path.resolve('app/javascript/config/extensions/three.js'),
    },
    fallback: {
      module: false,
    },
  },
  module: {
    rules: [
      {
        test: /\.(mjs|cjs|js|jsx)$/,
        loader: 'import-glob',
      },
      {
        test: /\.scss/,
        loader: 'import-glob',
      },
      {
        test: /\/icons\/.*.svg$/,
        type: 'asset/source',
      },
      {
        test: /\.(jpg|jpeg|png|gif|tiff|ico|eot|otf|ttf|woff|woff2)$/i,
        use: 'asset/resource',
      },
      {
        test: /\.(mjs|cjs|js|jsx)$/,
        include: /app\/javascript|\/cypress|@rolemodel\/lightning-cad/,
        loader: 'esbuild-loader',
        options: {
          loader: 'jsx',
          target: 'esnext',
        },
      },
      {
        test: /\.(sa|sc|c)ss$/i,
        use: [MiniCssExtractPlugin.loader, 'css-loader', 'postcss-loader'],
      },
    ],
  },
  optimization: {
    minimize: mode === 'production',
    minimizer: [
      new TerserPlugin({
        terserOptions: {
          keep_classnames: true,
          mangle: {
            keep_fnames: /^[A-Z]/,
          },
          compress: {
            keep_fnames: false,
          },
        },
      }),
      new CssMinimizerPlugin(),
    ],
  },
  plugins: [
    // cleans up the empty styles.js file Webpack generates
    new RemoveEmptyScriptsPlugin(),

    // Extract CSS into its own file for the Rails asset pipeline to pick up
    new MiniCssExtractPlugin(),

    // We're compiling all JS to a single application.js file
    new webpack.optimize.LimitChunkCountPlugin({
      maxChunks: 1,
    }),

    // Replace ENV variables at build time
    new webpack.DefinePlugin({
      'process.env.HONEYBADGER_API_KEY': JSON.stringify(
        process.env.HONEYBADGER_API_KEY
      ),
      'process.env.HONEYBADGER_ENV': JSON.stringify(
        process.env.HONEYBADGER_ENV
      ),
      'process.env.RAILS_ENV': JSON.stringify(process.env.RAILS_ENV),
      'process.env.SOURCE_VERSION': JSON.stringify(process.env.SOURCE_VERSION),
    }),

    // Send source maps to HoneyBadger in production for easier debugging
    mode === 'production' &&
      !process.env.CI &&
      new HoneybadgerSourceMapPlugin({
        apiKey: process.env.HONEYBADGER_API_KEY,
        assetsUrl: process.env.ASSETS_URL,
        revision: process.env.SOURCE_VERSION,
      }),
  ].filter(Boolean),
}
