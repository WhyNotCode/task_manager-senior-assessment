class WeatherService

  API_KEY = "990ec0dd047b4ed18bf03407261401"
  
  def self.get_weather(location)
    require 'net/http'
    require 'json'
    
    url = "http://api.weatherapi.com/v1/current.json?key=#{API_KEY}&q=#{location}"
    puts "DEBUG: Calling URL: #{url}"

    response = Net::HTTP.get(URI(url))
    puts "DEBUG: API response received"

    data = JSON.parse(response)
    puts "DEBUG: Response keys: #{data.keys}"
    
    # according to the docs and the swagger tool, the resp should look like this
    {
        location: data.dig("location", "name") || location,
        temp_c: data.dig("current", "temp_c"),
        temp_f: data.dig("current", "temp_f"),
        condition: data.dig("current", "condition", "text"),
        icon: data.dig("current", "condition", "icon"),
        success: true
      }
  end
end