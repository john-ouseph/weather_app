class WeatherController < ApplicationController
  def show
    address = 'New York'
    service = WeatherService.new(address)
    @weather_data = service.fetch_weather
  end
end