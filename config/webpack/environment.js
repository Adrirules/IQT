const { environment } = require('@rails/webpacker');

environment.config.merge({
  node: {
    global: true,
    __filename: 'mock',
    __dirname: 'mock'
  }
});

module.exports = environment;
