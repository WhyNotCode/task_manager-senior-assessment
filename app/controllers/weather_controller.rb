# Weather Controller
# =========================
# Handles displaying current weather information based on user IP or manual location input.
# Supports refreshing weather data by clearing cached entries.
# Utilizes WeatherService for API interactions and caching.
#
# Assumptions:
# - WeatherService exists and provides methods for fetching weather data. 
# - Routes are set up for index and refresh actions.
# =================================================================================


class WeatherController < ApplicationController
  def index
    # Get user IP (will be localhost in development)
    user_ip = request.remote_ip
    Rails.logger.info "Weather request from IP: #{user_ip}"
    
    # Get weather data (service handles caching)
    @weather_data = WeatherService.get_weather(user_ip)
    
    # Allow manual override via URL parameter (Search)
    if params[:location] && @weather_data[:success]
      # Don't cache manual lookups as frequently
      @weather_data = WeatherService.get_weather(params[:location])
      @manual_search = true
    else
      # Use auto-detection based on IP
      @weather_data = WeatherService.get_weather(user_ip)
      @manual_search = false
    end
    
    # Set page title
    @page_title = @weather_data[:success] ? 
                  "Weather in #{@weather_data[:location]}" : 
                  "Weather Info"
  end


  def refresh
    # Clear ALL weather cache
    if params[:clear_all] == 'true'
      Rails.cache.delete_matched("weather:*")
      notice = 'All weather cache cleared successfully!'
    else
      # Get user IP
      user_ip = request.remote_ip
    
      # Clear cache for specific user / location
      cache_key = if params[:location].present?
                    "weather:#{params[:location]}"
                  else
                    "weather:#{user_ip}"
                  end
      Rails.cache.delete(cache_key)
      notice = 'Weather data refreshed!'
    end
    redirect_to weather_path(location: params[:location]), notice: notice
  end
end