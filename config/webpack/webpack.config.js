// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.
const { generateWebpackConfig } = require('shakapacker')

// Bootstrap 5 y AdminLTE 4 no usan jQuery ni la global `Popper`, así que ya no
// hace falta el ProvidePlugin que exponía $, jQuery y Popper.
module.exports = generateWebpackConfig()
