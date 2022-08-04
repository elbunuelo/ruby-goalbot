module Api
  BASE_URL = configatron.api.url
  EVENTS_URL = "#{BASE_URL}/api/v1/sport/football/scheduled-events/{{date}}".freeze
  INCIDENTS_URL = "#{BASE_URL}/api/v1/event/{{match_id}}/incidents".freeze
  SEARCH_URL = "#{BASE_URL}/api/v1/search/{{search}}/0".freeze
  NEAR_EVENTS_URL = "#{BASE_URL}/api/v1/team/{{team_id}}/near-events".freeze

  FOOTBALL = 'Football'.freeze
  UNIQUE_TOURNAMENT = 'uniqueTournament'.freeze
  TEAM = 'team'.freeze
  MALE = 'M'.freeze

  class Client
    def self.fetch_events(date)
      url = Api::EVENTS_URL.sub '{{date}}', date
      response = HTTParty.get(url)

      response.parsed_response['events']&.map { |e| Event.from_hash(e) }
    end

    def self.fetch_incidents(event)
      url = Api::INCIDENTS_URL.sub '{{match_id}}', event.ss_id.to_s
      response = HTTParty.get(url)

      response.parsed_response['incidents']&.map { |i| Incident.from_hash(i.merge({ event: event })) }
    end

    def self._search(search, &block)
      url = Api::SEARCH_URL.sub '{{search}}', ERB::Util.url_encode(search)
      response = HTTParty.get(url)

      response.parsed_response['results'].detect(&block)
    end

    def self.search_team(team_search)
      result = _search(team_search) do |candidate|
        next unless candidate['type'] == Api::TEAM
        next unless candidate['entity']['sport']['name'] == Api::FOOTBALL

        true
      end

      Team.from_hash(result['entity']) if result
    end

    def self.next_event(team)
      url = Api::NEAR_EVENTS_URL.sub '{{team_id}}', team.ss_id
      response = HTTParty.get(url)
      events = response.parsed_response

      if events['previousEvent']['status']['type'] == 'inprogress'
        Event.from_hash(events['previousEvent'])
      elsif Time.at(events['nextEvent']['startTimestamp']).to_date == Date.today
        Event.from_hash(events['nextEvent'])
      end
    end
  end
end
