class IqtestsController < ApplicationController
  before_action :set_iqtest, only: [:show, :edit, :update, :destroy]

  def index
    @iqtests = Iqtest.all
  end

  def show
  end

  def new
    @iqtest = Iqtest.new
  end

  def create
    @iqtest = Iqtest.new(iqtest_params)
    @iqtest.save
    redirect_to iqtest_path(@iqtest), notice: 'IQ Test was successfully created.'
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
  end

  def iqtest_params
    params.require(:iqtest).permit(:name, :description)
  end

end
