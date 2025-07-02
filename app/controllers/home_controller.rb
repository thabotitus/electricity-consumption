class HomeController < ApplicationController
  def index
    readings = Reading.all

    @pagy, @records = pagy(readings)
  end
end
