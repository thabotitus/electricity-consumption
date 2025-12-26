# ApplicationHelper
#
# Provides helper methods for views, including pagination and custom calculations for electricity readings.
#
# Methods:
# - calculate_difference(collection, reading): Calculates the difference between the current and previous reading in a collection. Returns '-' if the result is negative.
# - calculate_day_zero(readings): Estimates the date when the reading will reach zero based on the rate of consumption. Returns '-' if not enough data or if the rate is non-positive.
# - average_daily_consumption(readings): Calculates the average daily consumption based on the first and most recent readings. Returns '-' if not enough data or if the average consumption is non-positive.
# - monthly_consumption_histogram(readings): Creates a histogram of average consumption per month based on the readings. Returns a hash where the keys are months (in 'YYYY-MM' format) and the values are the average consumption for that month.

module ApplicationHelper
  include Pagy::Frontend

  ELECTRICITY_USAGE_LEVELS = {
    low:     { units_per_day: 0..9,   status: 'success', icon: 'star' },  # good usage
    okay:    { units_per_day: 10..15, status: 'warning', icon: 'error-warning' },  # typical usage
    high:    { units_per_day: 16..Float::INFINITY, status: 'danger', icon: 'alarm-warning' } # high/inefficient usage
  }

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

  # Estimates the date when the reading will reach zero based on the average daily spend
  # calculated from the first reading of all time and the most recent reading.
  # Returns '-' if not enough data or if the average spend is non-positive.
  #
  # @param readings [Array] The collection of readings (ordered by created_at ascending)
  # @return [Date, String] The estimated zero date or '-'
  def calculate_day_zero(readings)
    return 0 if readings.empty? || readings.size < 2

    latest = readings.last
    # Find the first reading of all time
    first_reading = readings.first
    return Date.current.end_of_month unless first_reading && first_reading != latest

    days = (latest.created_at.to_date - first_reading.created_at.to_date).to_i
    return Date.current.end_of_month if days <= 0

    spend = first_reading.current_reading - latest.current_reading
    avg_daily_spend = average_daily_consumption(readings)

    return Date.current.end_of_month if avg_daily_spend <= 0

    days_to_zero = (latest.current_reading / avg_daily_spend).ceil

    (latest.created_at + days_to_zero.days).to_date
  end

  # Calculates the average daily consumption based on the first reading of all time and the most recent reading.
  # Returns '-' if not enough data or if the average consumption is non-positive.
  #
  # @param readings [Array] The collection of readings (ordered by created_at ascending)
  # @return [Float, String] The average daily consumption or '-'
  def average_daily_consumption(readings)
    return '-' if readings.empty? || readings.size < 2

    total_days = 0
    total_consumption = 0.0

    readings.each_cons(2) do |prev, current|
      days = (current.created_at.to_date - prev.created_at.to_date).to_i
      consumption = prev.current_reading - current.current_reading

      next if days <= 0 || consumption <= 0

      total_days += days
      total_consumption += consumption
    end

    return '-' if total_days <= 0 || total_consumption <= 0

    (total_consumption / total_days).round(2)
  end

  # Calculates the average daily consumption for the current month based on all readings.
  # It considers the difference between consecutive readings within the current month to account for top-ups.
  # Returns '-' if not enough data or if the average consumption is non-positive.
  #
  # @param readings [Array] The collection of readings (ordered by created_at ascending)
  # @return [Float, String] The average daily consumption for the current month or '-'
  def average_daily_consumption_current_month(readings)
    return '-' if readings.empty? || readings.size < 2

    current_month = Date.today.month
    current_year = Date.today.year

    monthly_readings = readings.select do |reading|
      reading.created_at.month == current_month && reading.created_at.year == current_year
    end

    return '-' if monthly_readings.size < 2

    total_days = 0
    total_consumption = 0.0

    monthly_readings.each_cons(2) do |prev, current|
      days = (current.created_at.to_date - prev.created_at.to_date).to_i
      consumption = prev.current_reading - current.current_reading

      next if days <= 0 || consumption <= 0

      total_days += days
      total_consumption += consumption
    end

    return '-' if total_days <= 0 || total_consumption <= 0

    (total_consumption / total_days).round(2)
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

  # Determines the electricity usage level based on the given units per day.
  # Matches the units per day to predefined levels in ELECTRICITY_USAGE_LEVELS.
  #
  # @param units_per_day [Integer, Float] The number of units consumed per day.
  # @return [Hash] A hash containing the usage level, status, and icon.
  def usage_level(units_per_day)
    ELECTRICITY_USAGE_LEVELS.each do |level, info|
      return {level:, status: info[:status], icon: info[:icon]} if info[:units_per_day].include?(units_per_day)
    end
  end
end
