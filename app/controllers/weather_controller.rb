class WeatherController < ApplicationController
  def index
    # Get user IP (will be localhost in development)
    user_ip = request.remote_ip
    Rails.logger.info "Weather request from IP: #{user_ip}"
    
    # Get weather data (service handles caching)
    @weather_data = WeatherService.get_weather(user_ip)
    
    # Allow manual override via URL parameter
    if params[:location] && @weather_data[:success]
      # Don't cache manual lookups as frequently
      manual_data = WeatherService.get_weather(params[:location])
      @weather_data = manual_data if manual_data[:success]
    end
    
    # Set page title
    @page_title = @weather_data[:success] ? 
                  "Weather in #{@weather_data[:location]}" : 
                  "Weather Info"
  end
end