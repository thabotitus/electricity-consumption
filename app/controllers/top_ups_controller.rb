class TopUpsController < ApplicationController
  def new
    @top_up = TopUp.new
    topups  = TopUp.order(created_at: :desc).all

    @pagy, @records = pagy(topups)
  end

  def create
    @topup = TopUp.new(top_up_params)

    if @topup.save
      redirect_to top_ups_path
    end
  end

  private

  def top_up_params
    params.require(:top_up).permit(:amount, :units, :date)
  end
end
