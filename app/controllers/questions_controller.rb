class QuestionsController < ApplicationController

  def new
    @iqtest = Iqtest.find(params[:iqtest_id])
    @question = Question.new
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
  end

=begin
  def edit
  end

  def update
    if @question.update(question_params)
      redirect_to question_url, notice: 'Question was successfully updated.'
    else
      render :edit
    end
  end
=end

  def destroy
    @question = Question.find(params[:id])
    @question.destroy
    redirect_to iqtest_path(@question.iqtest), status: :found
  end

  private
  def question_params
    params.require(:question).permit(:contentq)
  end
end
