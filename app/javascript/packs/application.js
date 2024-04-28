// app/javascript/packs/application.js
import Rails from '@rails/ujs';
import Turbolinks from 'turbolinks';
import * as ActiveStorage from '@rails/activestorage';
import 'channels';
import 'cocoon';

import 'core-js/stable';
import 'regenerator-runtime/runtime';

import './question_handling';
import './timer';


Rails.start();
Turbolinks.start();
ActiveStorage.start();
