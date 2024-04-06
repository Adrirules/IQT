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
