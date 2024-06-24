// app/javascript/packs/submit_order_with_last_response.js
document.addEventListener('turbolinks:load', function () {
  const optionsContainer = document.getElementById('options-container');
  console.log("Page loaded, initializing option selection handling.");

  if (optionsContainer) {
    optionsContainer.addEventListener('click', function (event) {
      let optionItem = event.target.closest('.option-item');
      if (!optionItem) return;

      let questionId = optionItem.dataset.questionId;
      let optionId = optionItem.dataset.optionId;
      let iqtestId = optionItem.dataset.iqtestId;

      console.log(`Option selected: Question ID = ${questionId}, Option ID = ${optionId}, IQTest ID = ${iqtestId}`);

      // Soumission de deux formulaires
      var lastQuestionForm = document.querySelector("#last-question-form");
      var orderForm = document.querySelector("#order-form");

      if (lastQuestionForm && orderForm) {
        // Remplir les champs du formulaire avec les données de l'option sélectionnée
        lastQuestionForm.querySelector("input[name='option_id']").value = optionId;
        lastQuestionForm.querySelector("input[name='question_id']").value = questionId;

        // Soumettre le formulaire de réponse
        lastQuestionForm.submit();

        // Soumettre le formulaire d'achat après un léger délai pour s'assurer que la réponse est enregistrée
        setTimeout(function () {
          orderForm.submit();
        }, 1000); // Ajustez le délai si nécessaire
      }

      // Envoi des données de sélection d'option au serveur
      fetch('/process_option_selection', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector("[name='csrf-token']").getAttribute('content')
        },
        body: JSON.stringify({ question_id: questionId, option_id: optionId, iqtest_id: iqtestId })
      })
        .then(response => {
          if (!response.ok) throw new Error('Failed to fetch next question');
          return response.json();
        })
        .then(data => {
          console.log("Response from server:", data);
          if (data.success) {
            if (data.nextQuestionUrl) {
              window.location.href = data.nextQuestionUrl;
            } else if (data.redirect_url) {
              // Rediriger directement vers la page de commande pour capturer l'adresse email
              window.location.href = data.redirect_url;
            }
          } else {
            console.error('Server error:', data.error);
          }
        })
        .catch(error => console.error('Error handling option selection:', error));
    });
  }
});
