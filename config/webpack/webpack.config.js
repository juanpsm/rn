// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.
const { generateWebpackConfig, merge } = require('shakapacker')
const webpack = require('webpack')

// jQuery, Popper y $ son globales esperadas por Bootstrap 4, AdminLTE y
// tempusdominus-core, que no las importan por sí mismas.
const providePlugin = {
  plugins: [
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
      Popper: ['popper.js', 'default']
    })
  ]
}

module.exports = merge(generateWebpackConfig(), providePlugin)
