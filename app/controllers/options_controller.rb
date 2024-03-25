class OptionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]
  before_action :set_question_and_iqtest
  before_action :set_question_and_option, only: [:show, :new, :create, :edit, :update, :destroy]
  before_action :authenticate_user!
  def new
    @option = Option.new
    authorize @option
  end

  def show
    authorize @option
  end

  def create
    @option = @question.options.build(option_params)
      authorize @option
    if @option.save
      redirect_to iqtest_question_path(@iqtest, @question), notice: 'Option was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @option
  end

  def update
    authorize @option
    if @option.update(option_params)
      redirect_to iqtest_question_path(@iqtest, @question), notice: 'Option was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @option
    @option.destroy
    redirect_to iqtest_question_path(@iqtest, @question), notice: 'Option was successfully destroyed.'
  end


  private

  def set_question_and_iqtest
    @question = Question.find(params[:question_id])
    @iqtest = @question.iqtest
  end

  def set_question_and_option
    @question = Question.find(params[:question_id])
    set_option
  end

  def set_option
  @option = if params[:id] == 'new'
              Option.new
            else
              Option.find_by(id: params[:id], question_id: @question.id)
            end
  end

  def option_params
    params.require(:option).permit(:reponse, :isreponsecorrect, :image)
  end
end
