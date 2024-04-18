// app/javascript/packs/ajax_setup.js
import Rails from '@rails/ujs';

Rails.ajax = (url, options) => {
  // Effectuer une requête fetch avec les mêmes paramètres que ceux passés à Rails.ajax
  return fetch(url, {
    method: options.type || 'GET',
    headers: options.headers,
    body: options.data,
    credentials: 'same-origin',
    redirect: 'follow',
  }).then(response => {
    return {
      ok: response.ok,
      status: response.status,
      statusText: response.statusText,
      json: () => response.json(),
      text: () => response.text(),
    };
  });
};

// Votre script JavaScript pour envoyer la requête AJAX
function envoyerRequeteAjax(url, data) {
  Rails.ajax(url, {
    type: 'POST', // Assurez-vous que la méthode est définie sur POST
    data: data,
  }).then(response => {
    // Gérer la réponse ici
    console.log(response);
  }).catch(error => {
    // Gérer les erreurs ici
    console.error(error);
  });
}
