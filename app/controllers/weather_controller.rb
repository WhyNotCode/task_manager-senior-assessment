class WeatherController < ApplicationController
  def index
    puts "DEBUG: WeatherController#index called"
    puts "DEBUG: Request IP: #{request.remote_ip}"
    puts "DEBUG: Params: #{params.inspect}"
    
    # For now, use a hardcoded location
    location = params[:location] || "Cape Town"
    
    @weather_data = WeatherService.get_weather(location)
    
    puts "DEBUG: Weather data ready: #{@weather_data[:success]}"
    puts "DEBUG: Combined keys: #{@weather_data.keys}"
  end
end