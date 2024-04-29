class QuestionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :first_question, :next_question, :show_score, :process_option_selection, :start_test]
  before_action :set_question, only: [:show, :edit, :update, :destroy]
  before_action :set_iqtest, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token

  def new
    @iqtest = Iqtest.find(params[:iqtest_id])
    @question = Question.new
    @question.iqtest = @iqtest # Assurez-vous que la nouvelle question est associée à l'IQTest
    authorize @question
  end

  def create
    @question = Question.new(question_params)
    @iqtest = Iqtest.find(params[:iqtest_id])
    @question.iqtest = @iqtest
    if @question.save
      redirect_to iqtest_path(@iqtest)
    else
      render :new, status: :unprocessable_entity
    end
    authorize @question
  end

  def show
    @iqtest = Iqtest.find(params[:iqtest_id])
    @question = Question.find(params[:id])
    authorize @question # Assurez-vous que la politique de la question est autorisée
    @options = @question.options.sort_by { |option| option.reponse.downcase }
    # Variable pour déterminer si l'utilisateur peut créer une option
    @options_creatable = policy(@question).create_option?
  end


  def edit
  end

  def update
    if @question.update(question_params)
      redirect_to iqtest_question_path(@question.iqtest, @question), notice: 'Question was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
      #render :edit
    end
  end

  def destroy
  @question = Question.find_by(id: params[:id])
    if @question
      @question.destroy
      redirect_to iqtest_path(@question.iqtest), notice: 'Question was successfully destroyed.'
    else
      redirect_to root_path, alert: 'Question not found.'
    end
     # skip_authorization
  end

  def first_question
    authorize :question, :first_question?
    first_iqtest = Iqtest.first
    redirect_to iqtest_question_path(first_iqtest, first_iqtest.questions.first)
  end

  def next_question
    current_iqtest = Iqtest.find(params[:iqtest_id])
    current_question = current_iqtest.questions.find(params[:id])
    authorize current_question

    next_question = current_iqtest.questions.find_by(id: current_question.id + 1)

    if next_question.nil? # Si c'est la dernière question
      next_question_url = iqtest_question_show_score_url(current_iqtest, current_question.iqtest.questions.last)
    else
      next_question_url = iqtest_question_url(current_iqtest, next_question)
    end

    render json: { nextQuestionUrl: next_question_url }
  end

=begin
  def show_score
    @user = params[:user_type].constantize.find(params[:user_id])
    score_result = calculate_score(@user)

    @iqtest = Iqtest.find(params[:iqtest_id])
    score_data = calculate_score(@user)  # Ceci renvoie maintenant un hash avec :iq et :correct_answers
    @score = score_data[:correct_answers]
    @iq_score = score_data[:iq] # Récupère le score de QI du hash
    authorize @iqtest, :show_score?
    render :show_score
  end
=end

  def show_score
    @user = current_user || GuestUser.find_by(session_id: session.id.to_s)
    return redirect_to root_path, alert: 'You are not authorized to view this page.' unless @user


    @iqtest = Iqtest.find(params[:iqtest_id])
    authorize @iqtest, :show_score?

    score_data = calculate_score(@user)
    @score = score_data[:correct_answers]
    @iq_score = score_data[:iq]

    # Récupérer toutes les questions et réponses pour le test
    @questions = @iqtest.questions.includes(:options)
    @user_responses = @user.responses.where(question: @questions).includes(:option)

    # Mapper les réponses pour accès facile dans la vue
    @responses_map = @user_responses.each_with_object({}) do |response, map|
      map[response.question_id] = response.option_id
    end

    render :show_score
  end


  def process_option_selection
    question = Question.find(params[:questionId])
    authorize question, :select_option?

    option = question.options.find(params[:optionId])
    user = current_user || GuestUser.find_or_create_by(session_id: session.id.to_s)

    # Met à jour la réponse existante ou en crée une nouvelle
    response = Response.find_or_initialize_by(responder: user, question: question)
    response.option = option
    response.save

    next_question = question.next_question
    if next_question
      render json: { success: true, nextQuestionUrl: iqtest_question_path(question.iqtest, next_question) }
    else
      # Redirection vers la méthode de calcul du score
      redirect_url = show_score_path(iqtest_id: question.iqtest_id, user_type: user.class.name, user_id: user.id)
      render json: { success: true, redirect_url: redirect_url }
    end
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, error: "Question or option not found" }, status: :not_found
  rescue Pundit::NotAuthorizedError
    render json: { success: false, error: "Not authorized to perform this action" }, status: :forbidden
  end


  # Démarre un nouveau test et redirige vers la première question du test
  def start_test
    # Trouver ou créer l'utilisateur (ou l'invité)
    user = current_user || GuestUser.find_or_create_by(session_id: session.id.to_s)

    # Supprimer les réponses précédentes de l'utilisateur pour ce test
    user.responses.delete_all

    # S'assure que la politique d'autorisation est respectée pour accéder à la première question
    authorize :question, :first_question?
    first_iqtest = Iqtest.first

    # Initialiser le temps de début du test
    first_iqtest.start_time = Time.current
    first_iqtest.save

    # Rediriger vers la première question du premier test IQ
    redirect_to iqtest_question_path(first_iqtest, first_iqtest.questions.first)
  end

  private
  def set_question
    @question = Question.find_by(id: params[:id])
    authorize @question if @question
  end

  def set_iqtest
    if @question
      @iqtest = @question.iqtest
    else
    # Gérez le cas où la question n'est pas trouvée, peut-être redirigez l'utilisateur
    # vers une autre page ou affichez un message d'erreur.
    end
  end

  def calculate_score(user)
    # Tableau de correspondance des scores de QI
    iq_scores = {
      0 => 44, 1 => 50, 2 => 56, 3 => 62, 4 => 68,
      5 => 74, 6 => 80, 7 => 86, 8 => 92, 9 => 98,
      10 => 104, 11 => 110, 12 => 116, 13 => 122,
      14 => 128, 15 => 135, 16 => 141, 17 => 148,
      18 => 156, 19 => 165, 20 => 175
    }

    # Calcule le nombre de réponses correctes
    correct_answers_count = user.responses.joins(:option).where(options: { isreponsecorrect: true }).count

    # Obtient le score de QI basé sur le nombre de réponses correctes
    iq_score = iq_scores[correct_answers_count] || 44 # Default à 44 si le score n'est pas défini (pour les cas où le nombre de réponses correctes pourrait dépasser 20)

    # Renvoie le score de QI et le nombre de réponses correctes
    { iq: iq_score, correct_answers: correct_answers_count }
  end

  def question_option_params
    # Construisez une liste des clés attendues en fonction des questions associées à cet IQTest
    question_keys = @iqtest.questions.map { |question| "question_#{question.id}_option_id" }
    # Retourne un tableau de symboles
    question_keys + [:iqtest_id, :id]
  end

  def question_params
    params.require(:question).permit(:contentq, :imageq, options_attributes: [:reponse, :isreponsecorrect, :image, :_destroy, :id])
  end



end
