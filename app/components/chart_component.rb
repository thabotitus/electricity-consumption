# frozen_string_literal: true

class ChartComponent < ViewComponent::Base
  attr_reader :readings, :top_ups

  def initialize(readings, top_ups)
    @readings = readings
    @top_ups  = top_ups
  end

  private

  def line_chart_data
    [
      { name: 'Readings', data: readings_data.to_h },
      { name: 'Top Ups',  data: top_ups_data.to_h }
    ]
  end

  def readings_data
    readings.map do |reading|
      [
        reading.created_at.strftime("%Y-%m-%d"),
        reading.current_reading
      ]
    end
  end

  def top_ups_data
    top_ups.map do |top_up|
      [
        top_up.date.strftime("%Y-%m-%d"),
        top_up.units
      ]
    end
  end

  def render_chart
    line_chart(line_chart_data, library: {
      elements: {
        point: {
          radius: 0
        },
        line: {
          tension: 0
        }
      },
      scales: {
        y: {
          display: true,
        }
      }
    })
  end
end
