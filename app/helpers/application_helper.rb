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
  def calculate_difference(reading)
    collection = Reading.order(created_at: :asc).all
    prev       = collection[collection.index(reading) - 1]
    result     = (prev.current_reading - reading.current_reading).round(2)

    return '-' if result.negative?
    result
  end

  # Estimates the date when the reading will reach zero based on the average daily spend for the current month.
  # Uses the first reading of the month and the most recent reading to calculate the average.
  # Returns '-' if not enough data or if the average spend is non-positive.
  #
  # @param readings [Array] The collection of readings (ordered by created_at ascending)
  # @return [Date, String] The estimated zero date or '-'
  def calculate_day_zero(readings)
    return '-' if readings.empty? || readings.size < 2

    latest = readings.last
    # Find the first reading of the current month
    first_of_month = readings.find { |r| r.created_at.month == latest.created_at.month && r.created_at.year == latest.created_at.year }
    return '-' unless first_of_month && first_of_month != latest

    days = (latest.created_at.to_date - first_of_month.created_at.to_date).to_i
    return '-' if days <= 0

    spend = first_of_month.current_reading - latest.current_reading
    avg_daily_spend = spend / days.to_f
    return '-' if avg_daily_spend <= 0

    days_to_zero = (latest.current_reading / avg_daily_spend).ceil
    (latest.created_at + days_to_zero.days).to_date
  end

  # Calculates the time in hours between the given reading and the previous one in the collection.
  # Assumes IDs are sequential and unique.
  # Returns '-' if there is no previous reading.
  #
  # @param collection [Array] The collection of readings
  # @param reading [Object] The current reading object
  # @return [Float, String] The hours difference or '-'
  def hours_since_last_reading(collection, reading)
    prev = collection.select { |r| r.id < reading.id }.max_by(&:id)
    return '-' unless prev
    ((reading.created_at - prev.created_at) / 1.hour).round
  end
end
