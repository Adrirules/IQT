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

  private

  def set_iqtest
    @iqtest = Iqtest.find(params[:id])
    authorize @iqtest
  end

  def iqtest_params
    params.require(:iqtest).permit(:name, :description, :price, :currency)
  end

end
