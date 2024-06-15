// Import des bibliothèques de base
import Rails from "@rails/ujs";
import Turbolinks from "turbolinks";
import * as ActiveStorage from "@rails/activestorage";
import "./channels";
import "cocoon";
import "core-js/stable";
import "regenerator-runtime/runtime";

// Import des scripts personnalisés
import "./packs/question_handling";
import "./packs/ajax_setup";
//import "./packs/timer";
import "./packs/submit_order_with_last_response";
import "./channels/index";

// Initialisation des bibliothèques
Rails.start();
Turbolinks.start();
ActiveStorage.start();

console.log("Application.js is loaded");
