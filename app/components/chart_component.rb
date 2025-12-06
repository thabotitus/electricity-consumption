# frozen_string_literal: true

class ChartComponent < ViewComponent::Base
  include ApplicationHelper
  include ChartHelper

  attr_reader :readings, :type, :chart_id, :title

  def initialize(readings:, type:, title:)
    @type     = type
    @readings = readings
    @chart_id = "chart-#{SecureRandom.hex(6)}"
    @title    = title
  end

  private

  def render_chart
    case type.to_sym
    when :line then render_line_chart
    when :bar then render_bar_chart
    end
  end

  def render_line_chart
    line_chart(readings_line_chart_data(readings), id: chart_id, library: {
      borderJoinStyle: 'round',
      fill: true,
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

  def render_bar_chart
    column_chart(monthly_consumption_histogram(readings), id: chart_id, library: {
      barThickness: 30,
      borderRadius: 9,
      borderWidth: 5
    })
  end
end
