require 'net/http'
require 'json'
require 'uri'


class WeatherService

  API_KEY = Rails.application.credentials.dig(:weatherapi, :api_key)
  BASE_URL = "http://api.weatherapi.com/v1"

  # get weather with caching
  def self.get_weather(ip_address = nil)

    # Determine user's location based on IP or default (for now)
    location_query = determine_location_query(ip_address)

    # Try to get it from our cache first
    cache_key = "weather:#{location_query}"
    cached_data = Rails.cache.read(cache_key)
    
    if cached_data
      puts "DEBUG: Cache hit for #{cache_key}"
      return cached_data
    end
    
    puts "DEBUG: Cache miss for #{cache_key}, fetching from API"


    # Fetch from API
    weather_data = fetch_weather_data(location_query)
    astronomy_data = fetch_astronomy_data(location_query)
    
    # Combine data
    combined_data = combine_data(weather_data, astronomy_data, location_query)
    
    # Cache for 15 minutes (WeatherAPI updates every 15-30 min)
    Rails.cache.write(cache_key, combined_data, expires_in: 15.minutes)
    
    combined_data
  end




  private
  
  def self.determine_location_query(ip_address)
    if ip_address && ip_address != "127.0.0.1" && ip_address != "::1"
      "auto:ip"
    else
      "Cape Town"  # Fallback 
    end
  end

  
  def self.fetch_weather_data(query)
    begin
      response = Net::HTTP.get_response(
        URI("#{BASE_URL}/current.json?key=#{API_KEY}&q=#{query}")
      )
      
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        { "error" => "API returned #{response.code}" }
      end
    rescue => e
      { "error" => e.message }
    end
  end

  
  def self.fetch_astronomy_data(query)
    begin
      response = Net::HTTP.get_response(
        URI("#{BASE_URL}/astronomy.json?key=#{API_KEY}&q=#{query}")
      )
      
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        { "error" => "Astronomy API failed" }
      end
    rescue => e
      { "error" => e.message }
    end
  end

  
  def self.combine_data(weather, astronomy, original_query)
    if weather["error"] || astronomy["error"]
      {
        location: format_location_name(original_query),
        error: weather["error"] || astronomy["error"],
        success: false
      }
    else
      {
        location: weather.dig("location", "name") || format_location_name(original_query),
        temp_c: weather.dig("current", "temp_c"),
        temp_f: weather.dig("current", "temp_f"),
        condition: weather.dig("current", "condition", "text"),
        icon: weather.dig("current", "condition", "icon"),
        sunrise: astronomy.dig("astronomy", "astro", "sunrise"),
        sunset: astronomy.dig("astronomy", "astro", "sunset"),
        last_updated: weather.dig("current", "last_updated"),
        humidity: weather.dig("current", "humidity"),
        wind_kph: weather.dig("current", "wind_kph"),
        success: true
      }
    end
  end
  
  def self.format_location_name(query)
    query == "auto:ip" ? "Your Location" : query
  end
end
