class IqtestsController < ApplicationController
  before_action :set_iqtest, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  def index
    @iqtests = policy_scope(Iqtest)
  end

  def show
  end

  def new
    @iqtest = Iqtest.new
    authorize @iqtest
  end

  def create
    @iqtest = current_user.iqtests.build(iqtest_params)
      if @iqtest.save
        redirect_to iqtest_path(@iqtest), notice: 'IQ Test was successfully created.'
      else
        render :new  # En cas d'échec, vous pouvez rediriger vers la page de création ou faire ce qui convient à votre cas
      end
    authorize @iqtest
  end

  def edit
  end

  def update
    if @iqtest.update(iqtest_params)
      redirect_to iqtests_url, notice: 'IQ Test was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    #@iqtest.destroy
    #redirect_to iqtests_path, notice: 'IQ Test was successfully destroyed.'
    @iqtest.destroy
    redirect_to iqtests_path, status: :found
  end

  def calculate_user_score
    total_questions = @iqtest.questions.count
    user_correct_answers = 0

    @iqtest.questions.each do |question|
      user_correct_answers += 1 if user_answer_correct?(question, selected_option_id)
    end

    calculate_score(total_questions, user_correct_answers)
  end



  private

  def set_iqtest
    @iqtest = Iqtest.find(params[:id])
    authorize @iqtest
  end

  def iqtest_params
    params.require(:iqtest).permit(:name, :description)
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

end
