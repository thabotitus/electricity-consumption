module ChartHelper
  # Creates a histogram of average consumption per month based on the readings.
  # Returns a hash where the keys are months (in 'YYYY-MM' format) and the values are the average consumption for that month.
  #
  # @param readings [Array] The collection of readings (ordered by created_at ascending)
  # @return [Hash] A histogram of average consumption per month
  def monthly_consumption_histogram(readings)
    return {} if readings.empty? || readings.size < 2

    histogram = Hash.new { |hash, key| hash[key] = [] }

    readings.each_cons(2) do |prev, current|
      month = current.created_at.strftime('%b')
      consumption = prev.current_reading - current.current_reading
      days = (current.created_at.to_date - prev.created_at.to_date).to_i
      next if days <= 0 || consumption <= 0

      histogram[month] << (consumption / days.to_f)
    end

    histogram.transform_values { |values| (values.sum / values.size).round(2) }
  end

  def readings_line_chart_data(readings)
    sorted_readings = readings.sort_by(&:created_at)
    return {} if sorted_readings.empty?

    filled_data = {}

    sorted_readings.each_cons(2) do |start_reading, end_reading|
      start_date  = start_reading.created_at.to_date
      end_date    = end_reading.created_at.to_date
      start_value = start_reading.current_reading
      end_value   = end_reading.current_reading

      filled_data[start_date.strftime('%Y-%m-%d')] = start_value

      days_diff = (end_date - start_date).to_i
      if days_diff > 1
        value_diff = end_value - start_value

        if value_diff.negative?
          (1...days_diff).each do |i|
            current_date       = start_date + i
            interpolated_value = start_value + (value_diff * i / days_diff.to_f)
            filled_data[current_date.strftime('%Y-%m-%d')] = interpolated_value.round(2)
          end
        else
          (1...days_diff).each do |i|
            current_date = start_date + i
            filled_data[current_date.strftime('%Y-%m-%d')] = start_value
          end
        end
      end
    end

    last_reading = sorted_readings.last
    if last_reading
      date_str = last_reading.created_at.strftime('%Y-%m-%d')
      filled_data[date_str] = last_reading.current_reading
    end

    filled_data
  end
end
