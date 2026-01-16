require 'net/http'
require 'json'
require 'uri'


class WeatherService

  # Use credentials for API key stored in rails creds
  API_KEY = Rails.application.credentials.dig(:weatherapi, :api_key)
  BASE_URL = "http://api.weatherapi.com/v1"

  # Fallback to ENV if credentials aren't set up yet
  if API_KEY.blank? && ENV['WEATHER_API_KEY'].present?
    API_KEY = ENV['WEATHER_API_KEY']
  end

  # Validate API key is present
  if API_KEY.blank?
    Rails.logger.warn "WeatherService: No API key found. Please set it in credentials or ENV."
  end


  # get weather with caching
  def self.get_weather(ip_address = nil)

    # Determine user's location based on IP or default (for now)
    location_query = determine_location_query(ip_address)

    # Try to get it from our cache first
    cache_key = "weather:#{location_query}"
    cached_data = Rails.cache.read(cache_key)
    
    if cached_data
      Rails.logger.debug "DEBUG: Cache hit for #{cache_key}"
      return cached_data
    end
    
    Rails.logger.debug "DEBUG: Cache miss for #{cache_key}, fetching from API"


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
  


  def self.determine_location_query(query)
    return "Cape Town" if query.nil? || query.to_s.strip.empty?

    # Convert to string for safe comparison
    query_str = query.to_s

    # First check if it's an IP address
    if is_ip_address?(query_str)
      if query_str == "127.0.0.1" || query_str == "::1"
        # Localhost - use default
        "Cape Town"
      else
        # Real IP - auto detect
        "auto:ip"
      end
    else
      # Not an IP - use the query as-is (for manual searches)
      query_str.strip
    end
  end

  def self.is_ip_address?(str)
    return false if str.nil? || str.empty?
    
    # Check for IPv4
    if str.match?(/\A(?:[0-9]{1,3}\.){3}[0-9]{1,3}\z/)
      # Validate each octet is 0-255
      octets = str.split('.').map(&:to_i)
      return octets.all? { |octet| octet >= 0 && octet <= 255 }
    end

    # Check for IPv6
    return true if str.match?(/\A([0-9a-fA-F]{0,4}:){2,7}[0-9a-fA-F]{0,4}\z/)
    return true if str == "::1"
    false
  end

  def self.build_uri(endpoint, query)
    # handle spaces and special characters on the URI
    encoded_query = URI.encode_www_form_component(query)
    URI("#{BASE_URL}/#{endpoint}.json?key=#{API_KEY}&q=#{encoded_query}")
  end

  
  def self.fetch_weather_data(query)
    # Check the API key is present
    return { "error" => "API key not configured" } if API_KEY.blank?

    begin
      uri = build_uri("current", query)
      response = Net::HTTP.get_response(uri)
      
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      elsif response.code == "403"
        { "error" => "Invalid API key or quota exceeded" }
      else
        { "error" => "Weather API error: #{response.code}" }
      end
    rescue SocketError => e
      { "error" => "Network error: Unable to connect to weather service" }
    rescue JSON::ParserError => e
      { "error" => "Invalid response from weather service" }
    rescue => e
      { "error" => "Unexpected error: #{e.message}" }
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
