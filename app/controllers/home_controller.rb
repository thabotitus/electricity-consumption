class HomeController < ApplicationController
  def index
    readings = Reading.order(created_at: :desc).all

    @pagy, @records = pagy(readings)
  end
end
