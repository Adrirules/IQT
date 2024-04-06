// app/javascript/packs/application.js
require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")
require("cocoon")

import 'core-js/stable';
import 'regenerator-runtime/runtime';
import './ajax_setup.js';
