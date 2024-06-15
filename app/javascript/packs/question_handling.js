// app/javascript/packs/question_handling.js
console.log("question_handling.js is loaded");

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
