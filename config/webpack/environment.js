const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

// Add any plugins you need here
environment.plugins.append('Provide', new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: 'jquery',
  Popper: ['popper.js', 'default']
}))

module.exports = environment
