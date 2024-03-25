class QuestionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :first_question]
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
      skip_authorization
  end

  def next_question
    current_question = Question.find(params[:id])
    next_question = current_question.next_question

    redirect_to iqtest_question_path(params[:iqtest_id], next_question)
  end

  def first_question
    authorize :question, :first_question?
    first_iqtest = Iqtest.first
    redirect_to iqtest_question_path(first_iqtest, first_iqtest.questions.first)
  end

  def first_question?
    # Autoriser l'accès si l'utilisateur est connecté
    user.present?
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


  def question_params
    #params.require(:question).permit(:contentq)
    params.require(:question).permit(:contentq, :imageq, options_attributes: [:reponse, :isreponsecorrect, :image, :_destroy, :id])
  end
end
