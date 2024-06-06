const { environment } = require('@rails/webpacker')

// Ajouter la configuration de node pour Webpack 5
environment.config.merge({
  node: {
    __dirname: false,
    __filename: false,
    global: true,
    dgram: 'empty',
    fs: 'empty',
    net: 'empty',
    tls: 'empty',
    child_process: 'empty'
  }
});

module.exports = environment
