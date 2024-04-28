document.addEventListener('turbolinks:load', function () {
  let startTime = new Date(document.getElementById('start-time').value);
  let endTime = new Date(startTime.getTime() + 1200000); // 20 minutes plus tard

  let timer = setInterval(function () {
    let now = new Date();
    let distance = endTime - now;
    let minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
    let seconds = Math.floor((distance % (1000 * 60)) / 1000);
    seconds = seconds < 10 ? '0' + seconds : seconds; // Ajout du zéro pour les secondes < 10

    document.getElementById('timer').textContent = minutes + "m " + seconds + "s ";

    if (distance < 0) {
      clearInterval(timer);
      document.getElementById('timer').textContent = "EXPIRÉ";
      window.location.href = '<%= show_score_path(@iqtest, current_user) %>'; // Redirige vers la page des scores
    }
  }, 1000);
});
