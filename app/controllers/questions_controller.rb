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
    #@iqtest = Iqtest.find(params[:iqtest_id])
    # Vous pouvez également récupérer les options associées à la question si nécessaire
    #@options = @question.options

    @iqtest = Iqtest.find(params[:iqtest_id])
    @question = Question.find(params[:id])
    authorize @question # Assurez-vous que la politique de la question est autorisée
    @options = @question.options
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




  def first_question
    authorize :question, :first_question?
    first_iqtest = Iqtest.first
    redirect_to iqtest_question_path(first_iqtest, first_iqtest.questions.first)
  end
=begin
  def show_score
    puts "Entering show_score method..."
    @iqtest = Iqtest.find(params[:iqtest_id])
    authorize @iqtest  # S'assurer que l'utilisateur est autorisé à voir le score pour cet IQTest

    user_correct_answers = 0

    puts "User responses for scoring: #{session[:user_responses].inspect}"

    # Utilise session[:user_responses] pour récupérer les sélections de l'utilisateur
    session[:user_responses]&.each do |question_id_str, response|
      question_id = question_id_str.to_i  # Conversion de la clé en entier si nécessaire
      puts "Processing response for question ID: #{question_id}"

      question = Question.find_by(id: question_id)

      if question
        selected_option_id = response[:option_id].to_i  # S'assurer que l'option_id est un entier
        selected_option = question.options.find_by(id: selected_option_id)

        if selected_option&.isreponsecorrect?
          user_correct_answers += 1
          puts "Correct answer for question #{question_id}, option_id=#{selected_option_id}"
        else
          puts "Incorrect or missing option for question #{question_id}, selected_option_id=#{selected_option_id}"
        end
      else
        puts "Question not found for ID: #{question_id}"
      end
    end

    puts "Total correct answers: #{user_correct_answers}"
    @score = calculate_score(@iqtest.questions.count, user_correct_answers)

    # Assure-toi de nettoyer la session après utilisation
    session.delete(:user_responses)
    puts "Session cleaned. Remaining session data: #{session.inspect}"

    render 'show_score'
  end
=end


  def show_score
    @user = params[:user_type].constantize.find(params[:user_id])
    @iqtest = Iqtest.find(params[:iqtest_id])
    @score = calculate_score(@user)  # Obtient le score calculé
    authorize @iqtest, :show_score?  # Utilisez l'Iqtest pour l'autorisation
    # Rend la vue qui affiche le score
    render :show_score
  end


  def process_option_selection
    question = Question.find(params[:questionId])
    authorize question, :select_option?

    option = question.options.find(params[:optionId])
    user = current_user || GuestUser.find_or_create_by(session_id: session.id.to_s)
    response = Response.create(responder: user, question: question, option: option)

    next_question = question.next_question
    if next_question
      render json: { success: true, nextQuestionUrl: iqtest_question_path(question.iqtest, next_question) }
    else
      # Redirection vers la méthode de calcul du score
      score = calculate_score(user)
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

  def calculate_user_score(selected_option_id)
    total_questions = @iqtest.questions.count
    user_correct_answers = 0

    @iqtest.questions.each do |question|
      user_correct_answers += 1 if user_answer_correct?(question, selected_option_id)
    end
    score = calculate_score(total_questions, user_correct_answers) # Stockez la valeur de retour dans une variable

    # Point de contrôle : Afficher les informations pour déboguer le calcul du score utilisateur
    puts "User correct answers: #{user_correct_answers}"
    puts "Calculated score: #{score}"

    score
  end
  def user_answer_correct?(question, selected_option_id)
    # Logique pour vérifier si la réponse de l'utilisateur à une question est correcte
    correct_options = question.options.where(isreponsecorrect: true)
    user_option = question.options.find_by(id: selected_option_id)

    puts "Correct options: #{correct_options.pluck(:id)}"
    puts "User option: #{user_option&.id}"

    return false unless user_option

    correct = user_option.isreponsecorrect? && correct_options.exists?(user_option.id)
    puts "User answer correct? #{correct}"

    correct
  end

=begin
  def calculate_score(total_questions, user_correct_answers)
    score_chart = {
      0 => 44, 1 => 50, 2 => 56, 3 => 62, 4 => 68,
      5 => 74, 6 => 80, 7 => 86, 8 => 92, 9 => 98,
      10 => 104, 11 => 110, 12 => 116, 13 => 122,
      14 => 128, 15 => 135, 16 => 141, 17 => 148,
      18 => 156, 19 => 165, 20 => 175
    }

    score = score_chart[user_correct_answers] || 0
    score
  end
=end
  def calculate_score(user)
    correct_answers = user.responses.joins(:option).where(options: { isreponsecorrect: true }).count
    correct_answers  # Retourne simplement le nombre de réponses correctes
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
