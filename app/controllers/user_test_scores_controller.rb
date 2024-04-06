class UserTestScoresController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:collect_responses]
  def create
    if user_signed_in?
      Rails.logger.info "Utilisateur connecté : #{current_user.email}"
      @user_test_score = current_user.user_test_scores.build(user_test_score_params)
    else
      Rails.logger.info "Utilisateur non connecté : #{session[:temp_user_id]}"
      session[:temp_user_test_score] ||= []
      session[:temp_user_test_score] << user_test_score_params.merge(iqtest_id: params[:iqtest_id])
      Rails.logger.info "Contenu de la session : #{session[:temp_user_test_score]}"
    end

    # Sauvegarde du score pour les utilisateurs connectés
    if @user_test_score&.save
      redirect_to_next_question_or_result(@user_test_score)
    else
      flash[:error] = "Erreur lors de la sauvegarde du score."
      redirect_to root_path
    end
  end

=begin
  def collect_responses
    response_json = { score: 5 }
    render json: response_json
    if user_signed_in?
      # Si l'utilisateur est connecté, il est redirigé vers la méthode create pour traiter la réponse
      puts "User is signed in: #{current_user.email}"
      create
    else
      puts "User is not signed in"
      # Vérifie si les paramètres nécessaires sont présents dans la requête
      if user_test_score_params.present? && user_test_score_params[:question_id].present? && user_test_score_params[:option_id].present?
        # Si les paramètres sont présents, les réponses sont temporairement stockées en session
        session[:temp_user_test_score] ||= []
        session[:temp_user_test_score] << user_test_score_params.merge(iqtest_id: params[:iqtest_id])
        Rails.logger.info "Contenu de la session : #{session[:temp_user_test_score]}"

        # Redirection vers la prochaine question ou les résultats finaux
      else
        # Si les paramètres nécessaires sont absents, rediriger avec un message d'erreur
        flash[:error] = "Missing parameters for collecting responses."
        redirect_to root_path
      end
    end
  end
=end

  def collect_responses
    skip_authorization
    response_json = { score: 5 }
    respond_to do |format|
      format.json { render json: response_json }
    end
  end

  private

  def user_test_score_params
    params.require(:user_test_score).permit(:question_id, :option_id)
  end

  # Méthode pour rediriger l'utilisateur vers la prochaine question ou les résultats finaux
  def redirect_to_next_question_or_result(user_test_score)
    if user_signed_in?
      # Redirection vers la question suivante si l'utilisateur est connecté
      redirect_to next_question_path(question_id: user_test_score.question_id)
    else
      # Redirection vers la page de résultats si l'utilisateur n'est pas connecté
      redirect_to iqtest_result_path(params[:iqtest_id])
    end
  end
end
