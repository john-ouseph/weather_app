require 'httparty'

class WeatherService
  BASE_URL = 'https://api.openweathermap.org/data/2.5/weather'
  CACHE_EXPIRY = 30.minutes.to_i

  def initialize(address)
    @address = address
  end

  def fetch_weather
    fetch_and_cache_weather
  end

  private

  def cache_key
    "weather:#{@address}"
  end

  def cached_weather
    # Use $redis to fetch from cache
    cached_data = $redis.get(cache_key)
    if cached_data
      puts "Data fetched from cache"
      JSON.parse(cached_data)
    else
      nil
    end
  end

  def fetch_and_cache_weather
    # Fetch from API if not cached
    response = HTTParty.get(BASE_URL, verify: false, query: {
      q: @address,
      appid: '247ca4af79a7e0a9a1938538494a76d3',
      units: 'metric'
    })

    if response.success?
      data = parse_response(response)
      $redis.set(cache_key, data.to_json, ex: CACHE_EXPIRY) # Cache with expiry
      data
    else
      { error: response['message'] || 'Unable to retrieve weather data' }
    end
  end

  def parse_response(response)
    data = response.parsed_response
    {
      temperature: data.dig('main', 'temp'),
      high: data.dig('main', 'temp_max'),
      low: data.dig('main', 'temp_min'),
      description: data.dig('weather', 0, 'description')
    }
  end
end