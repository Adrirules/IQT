document.addEventListener('turbolinks:load', function () {
  console.log("Document ready! Setting up event listeners.");

  const optionsContainer = document.getElementById('options-container');

  if (optionsContainer) {
    console.log("Options container found. Adding event listener.");
    optionsContainer.addEventListener('click', function (event) {
      console.log("Options container clicked.");
      let optionItem = event.target.closest('.option-item');
      if (!optionItem) {
        console.log("Click was not on an option item.");
        return;
      }

      console.log("Option item clicked.", optionItem);

      let questionId = optionItem.dataset.questionId;
      let optionId = optionItem.dataset.optionId;
      let iqtestId = optionItem.dataset.iqtestId;

      console.log(`Processing selection: Question ID = ${questionId}, Option ID = ${optionId}, IQTest ID = ${iqtestId}`);

      fetch(`/process_option_selection`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector("[name='csrf-token']").getAttribute('content')
        },
        body: JSON.stringify({ questionId, optionId, iqtestId })
      })
        .then(response => {
          if (!response.ok) throw new Error('Failed to fetch next question');
          return response.json();
        })
        .then(data => {
          if (data.success) {
            if (data.nextQuestionUrl) {
              console.log("Redirecting to next question:", data.nextQuestionUrl);
              window.location.href = data.nextQuestionUrl;
            } else if (data.redirect_url) {
              console.log("Redirecting to score page:", data.redirect_url);
              window.location.href = data.redirect_url;
            } else {
              console.error('Error: No URL provided for redirection.');
            }
          } else {
            console.error('Server error:', data.error);
          }
        })
        .catch(error => console.error('Error handling option selection:', error));
    });
  } else {
    console.log("Options container not found.");
  }
});
