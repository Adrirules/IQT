class UserTestScoresController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:collect_responses]

  def create
    if user_signed_in?
      Rails.logger.info "Utilisateur connecté : #{current_user.email}"
      @user_test_score = current_user.user_test_scores.build(user_test_score_params.merge(user_type: 'User'))
    else
      Rails.logger.info "Utilisateur non connecté"
      # Trouver ou créer un GuestUser basé sur la session ID.
      guest_user = GuestUser.find_or_create_by_session(session.id.to_s)
      @user_test_score = guest_user.user_test_scores.build(user_test_score_params.merge(user_type: 'GuestUser'))
    end

    if @user_test_score.save
      redirect_to_next_question_or_result(@user_test_score)
    else
      flash[:error] = "Erreur lors de la sauvegarde du score."
      redirect_to root_path
    end
  end
=begin
  def collect_responses
    skip_authorization
    # Cette méthode pourrait être utilisée pour collecter les réponses via AJAX
    response_json = { score: 5 }
    render json: response_json
  end
=end

  private

  def user_test_score_params
    params.require(:user_test_score).permit(:question_id, :option_id, :iqtest_id)
  end

  def redirect_to_next_question_or_result(user_test_score)
    next_question = Question.find(user_test_score.question_id).next_question
    if next_question
      redirect_to question_path(next_question)
    else
      redirect_to iqtest_result_path(user_test_score.iqtest_id)
    end
  end
end
