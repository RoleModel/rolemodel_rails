require 'rails'

module LightningCad
  class WebpackGenerator < Rails::Generators::Base
    source_root File.expand_path('./templates', __dir__)

    def add_experimental_features
      # copy_file 'webpack.config.js', 'webpack.config.js'
      say "Adding experimental features to the config"

      experiments = <<-JS
  experiments: {
    topLevelAwait: true
  },
      JS

      insert_into_file 'webpack.config.js', experiments, before: "  output: {"
    end

    def add_resolve_fallback
      fallback = <<~JS
        ,
            fallback: {
              module: false
            }
      JS

      insert_into_file 'webpack.config.js', fallback, after: "extensions: ['.js', '.jsx']"
    end

    def add_resolve_aliases
      say 'Adding aliases to the config'
      alias_js = <<-JS
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

      // LCAD uses `require` to bring in mathjs, but rails 7 apps uses `import`, so there are
      // two mathjs module instances in play, and without this line both end up in the final bundle.
      // TODO: Once LCAD migrates to ES Modules, this line can be removed.
      mathjs: path.resolve('node_modules/mathjs/lib/esm'),

      // Webpack apparently doesn't support the * in package.imports, so we need to duplicate
      // package.imports here for webpack.
      '#components': path.resolve('app/javascript/components'),
      '#shared': path.resolve('app/javascript/shared'),
      '#three': path.resolve('app/javascript/config/extensions/three.js')
    },
      JS

      insert_into_file 'webpack.config.js', alias_js, before: "    fallback: {"
    end

    def add_loaders
      say 'Adding loaders to the config'

      loaders = <<-JS
      {
        test: /\.(mjs|cjs|js|jsx)$/,
        loader: 'import-glob'
      },
      {
        test: /\.scss/,
        loader: 'import-glob'
      },
      JS

      insert_into_file 'webpack.config.js', loaders, after: "rules: [\n"
    end

    def update_esbuild_loader
      say 'Updating esbuild loader in the config'

      insert_into_file 'webpack.config.js', "        include: /app\\/javascript|@rolemodel\\/lightning-cad/,\n", before: "        loader: 'esbuild-loader',"
      gsub_file 'webpack.config.js', 'es2021', 'esnext'
    end

    def add_terser_plugin_options
      say 'Updating the terser plugin options in the config'

      terserPlugin = <<-JS
      new TerserPlugin({
        terserOptions: {
          keep_classnames: true,
          mangle: {
            keep_fnames: /^[A-Z]/,
          },
          compress: {
            keep_fnames: false,
          }
        }
      }),
      JS

      gsub_file 'webpack.config.js', "      new TerserPlugin(),\n", terserPlugin
    end
  end
end
