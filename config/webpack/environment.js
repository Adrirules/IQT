const { environment } = require('@rails/webpacker')

environment.config.merge({
  node: false
})

module.exports = environment
