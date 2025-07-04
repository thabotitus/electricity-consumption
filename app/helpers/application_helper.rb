module ApplicationHelper
  include Pagy::Frontend

  def calculate_difference(collection, reading)
    prev   = collection[collection.index(reading) - 1]
    result = (prev.current_reading - reading.current_reading).round(2)

    return '-' if result.negative?
    result
  end
end
