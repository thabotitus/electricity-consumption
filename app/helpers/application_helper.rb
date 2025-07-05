# ApplicationHelper
#
# Provides helper methods for views, including pagination and custom calculations for electricity readings.
#
# Methods:
# - calculate_difference(collection, reading): Calculates the difference between the current and previous reading in a collection. Returns '-' if the result is negative.
# - calculate_day_zero(readings): Estimates the date when the reading will reach zero based on the rate of consumption. Returns '-' if not enough data or if the rate is non-positive.

module ApplicationHelper
  include Pagy::Frontend

  # Calculates the difference between the current and previous reading in the collection.
  # Returns '-' if the result is negative.
  #
  # @param collection [Array] The collection of readings
  # @param reading [Object] The current reading object
  # @return [Float, String] The difference or '-'
  def calculate_difference(collection, reading)
    prev   = collection[collection.index(reading) - 1]
    result = (prev.current_reading - reading.current_reading).round(2)

    return '-' if result.negative?
    result
  end

  # Estimates the date when the reading will reach zero based on the rate of consumption.
  # Returns '-' if not enough data or if the rate is non-positive.
  #
  # @param readings [Array] The collection of readings
  # @return [Date, String] The estimated zero date or '-'
  def calculate_day_zero(readings)
    return '-' if readings.empty? || readings.size < 2

    latest = readings.last
    previous = readings[-2]
    rate = previous.current_reading - latest.current_reading

    return '-' if rate <= 0

    days_to_zero = (latest.current_reading / rate).ceil
    (latest.created_at + days_to_zero.days).to_date
  end
end
