class ReadingsController < ApplicationController
  def new
    @reading = Reading.new
    readings = Reading.order(created_at: :desc).all

    @pagy, @records = pagy(readings)
  end

  def create
    @reading = Reading.new(reading_params)

    if @reading.save
      redirect_to root_path
    end
  end

  private

  def reading_params
    params.require(:reading).permit(:current_reading)
  end
end
