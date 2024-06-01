// app/assets/javascripts/submit_order_with_last_response.js
document.addEventListener("DOMContentLoaded", function () {
  var lastQuestionForm = document.querySelector("#last-question-form");
  var orderForm = document.querySelector("#order-form");

  if (lastQuestionForm && orderForm) {
    var options = document.querySelectorAll(".option-item");
    options.forEach(function (option) {
      option.addEventListener("click", function () {
        // Remplir les champs du formulaire avec les données de l'option sélectionnée
        var optionId = option.getAttribute("data-option-id");
        var questionId = option.getAttribute("data-question-id");
        lastQuestionForm.querySelector("input[name='option_id']").value = optionId;
        lastQuestionForm.querySelector("input[name='question_id']").value = questionId;

        // Soumettre le formulaire de réponse
        lastQuestionForm.submit();

        // Soumettre le formulaire d'achat après un léger délai pour s'assurer que la réponse est enregistrée
        setTimeout(function () {
          orderForm.submit();
        }, 1000); // Ajustez le délai si nécessaire
      });
    });
  }

  // Fonction pour gérer la soumission et la redirection après sélection de l'option
  function handleOptionSelection(questionId, optionId) {
    fetch(`/process_option_selection`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      },
      body: JSON.stringify({ question_id: questionId, option_id: optionId })
    })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          if (data.nextQuestionUrl) {
            // Rediriger vers la prochaine question
            window.location.href = data.nextQuestionUrl;
          } else if (data.redirect_url) {
            // Rediriger vers la page de paiement
            window.location.href = data.redirect_url;
          }
        } else {
          console.error("Erreur: ", data.error);
        }
      })
      .catch(error => console.error('Erreur:', error));
  }

  // Ajouter des gestionnaires d'événements pour les options
  document.querySelectorAll('.option-item').forEach(option => {
    option.addEventListener('click', function () {
      const questionId = this.dataset.questionId;
      const optionId = this.dataset.optionId;
      handleOptionSelection(questionId, optionId);
    });
  });
});
