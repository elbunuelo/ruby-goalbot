module Sofascore
  BASE_URL = 'https://api.sofascore.com'.freeze
  EVENTS_URL = "#{BASE_URL}/api/v1/sport/football/scheduled-events/{{date}}".freeze
  INCIDENTS_URL = "#{BASE_URL}/api/v1/event/{{match_id}}/incidents".freeze

  class Client
    def self.fetch_events(date)
      url = EVENTS_URL.sub '{{date}}', date
      response = HTTParty.get(url)

      response.parsed_response['events']
    end

    def self.fetch_incidents(match_id)
      url = INCIDENTS_URL.sub '{{match_id}}', "#{match_id}"
      response = HTTParty.get(url)

      response.parsed_response['incidents']
    end
  end
end
