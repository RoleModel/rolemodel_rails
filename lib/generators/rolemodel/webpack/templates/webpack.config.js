import path from 'path'
import webpack from 'webpack'
import TerserPlugin from 'terser-webpack-plugin'
import HoneybadgerSourceMapPlugin from '@honeybadger-io/webpack'
import MiniCssExtractPlugin from 'mini-css-extract-plugin'
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
      './app/assets/stylesheets/application.scss'
    ],
    mailer: [
      './app/assets/stylesheets/mailer.scss'
    ]
  },
  output: {
    filename: '[name].js',
    sourceMapFilename: '[file].map',
    path: path.resolve('app/assets/builds')
  },
  resolve: {
    modules: ['node_modules'],
    extensions: ['.js', '.jsx']
  },
  module: {
    rules: [
      {
        test: /\/icons\/.*.svg$/,
        type: 'asset/source'
      },
      {
        test: /\.(jpg|jpeg|png|gif|tiff|ico|eot|otf|ttf|woff|woff2)$/i,
        use: 'asset/resource'
      },
      {
        test: /\.(mjs|cjs|js|jsx)$/,
        loader: 'esbuild-loader',
        options: {
          loader: 'jsx',
          target: 'es2021'
        },
        // ES Module has stricter rules than CommonJS, so file extensions must be
        // used in import statements. To ease migration from CommonJS to ESM,
        // uncomment the fullySpecified option below to allow Webpack to use a
        // looser set of rules. Not recommend for new projects or the long term.
        resolve: {
          // Allows importing JS files without specifying the file extension.
          fullySpecified: false
        }
      },
      {
        test: /\.(sa|sc|c)ss$/i,
        use: [
          MiniCssExtractPlugin.loader,
          {
            loader: 'css-loader',
            options: {
              url: false
            }
          },
          'postcss-loader'
        ]
      }
    ]
  },
  optimization: {
    minimize: mode === 'production',
    minimizer: [
      new TerserPlugin(),
      new CssMinimizerPlugin()
    ]
  },
  plugins: [
    // Extract CSS into its own file for the Rails asset pipeline to pick up
    new MiniCssExtractPlugin(),

    // We're compiling all JS to a single application.js file
    new webpack.optimize.LimitChunkCountPlugin({
      maxChunks: 1
    }),

    // Replace ENV variables at build time
    new webpack.DefinePlugin({
      'process.env.HONEYBADGER_API_KEY': JSON.stringify(process.env.HONEYBADGER_API_KEY),
      'process.env.HONEYBADGER_ENV': JSON.stringify(process.env.HONEYBADGER_ENV),
      'process.env.RAILS_ENV': JSON.stringify(process.env.RAILS_ENV),
      'process.env.SOURCE_VERSION': JSON.stringify(process.env.SOURCE_VERSION)
    }),

    // Send source maps to HoneyBadger in production for easier debugging
    (mode === 'production' && !process.env.CI) && new HoneybadgerSourceMapPlugin({
      apiKey: process.env.HONEYBADGER_API_KEY,
      assetsUrl: process.env.ASSETS_URL,
      revision: process.env.SOURCE_VERSION
    })
  ].filter(Boolean)
}
