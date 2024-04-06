class QuestionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :first_question, :next_question, :show_score]
  before_action :set_question, only: [:show, :edit, :update, :destroy]
  before_action :set_iqtest, only: [:show, :edit, :update, :destroy]

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
    current_question = Question.find(params[:id])
    authorize current_question

    next_question = current_question.next_question

    if next_question.nil? # Si c'est la dernière question
      redirect_to iqtest_question_show_score_path(params[:iqtest_id], current_question.iqtest.questions.last)
    else
      redirect_to iqtest_question_path(params[:iqtest_id], next_question)
    end
  end



  def first_question
    authorize :question, :first_question?
    first_iqtest = Iqtest.first
    redirect_to iqtest_question_path(first_iqtest, first_iqtest.questions.first)
  end

  def show_score
    @iqtest = Iqtest.find(params[:iqtest_id])
    selected_option_ids = params.permit(:selected_option_id) # Récupère les paramètres de la requête
    authorize @iqtest
    # Vérifie si selected_option_ids est nil ou s'il contient les valeurs attendues
    if selected_option_ids.present?
      # Récupère toutes les questions associées à cet IQTest
      questions = @iqtest.questions

      # Initialise un compteur pour les réponses correctes de l'utilisateur
      user_correct_answers = 0

      # Parcourt chaque question pour vérifier si l'option sélectionnée par l'utilisateur est la réponse correcte
      questions.each do |question|
        # Obtient l'ID de l'option sélectionnée par l'utilisateur pour cette question
        selected_option_id = selected_option_ids["question_#{question.id}_option_id"]

        # Récupère l'option sélectionnée par l'utilisateur
        selected_option = question.options.find_by(id: selected_option_id)

        # Vérifie si l'option sélectionnée est correcte pour cette question
        if selected_option && selected_option.isreponsecorrect?
          user_correct_answers += 1
        end
      end

      # Utilise le nombre de réponses correctes de l'utilisateur pour calculer le score
      @score = calculate_score(questions.count, user_correct_answers)

      # Affiche les informations de débogage
      puts "Total questions: #{questions.count}"
      puts "User correct answers: #{user_correct_answers}"
      puts "Calculated score: #{@score}"

      render 'show_score'
    else
      # Traitez le cas où selected_option_ids est nil ou vide
      # Peut-être rediriger vers une autre page ou afficher un message d'erreur
    end
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

    calculate_score(total_questions, user_correct_answers)

    # Point de contrôle : Afficher les informations pour déboguer le calcul du score utilisateur
    puts "User correct answers: #{user_correct_answers}"
    puts "Calculated score: #{calculated_score}"

    calculated_score
  end

  def user_answer_correct?(question, selected_option_id)
    # Logique pour vérifier si la réponse de l'utilisateur à une question est correcte
    correct_options = question.options.where(isreponsecorrect: true)
    user_option = question.options.find_by(id: selected_option_id)

    return false unless user_option

    user_option.isreponsecorrect? && correct_options.include?(user_option)
  end

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

  def question_params
    params.require(:question).permit(:contentq, :imageq, options_attributes: [:reponse, :isreponsecorrect, :image, :_destroy, :id])
  end


end
