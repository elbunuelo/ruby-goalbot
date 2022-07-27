class EventManager
  def self.todays_events
    today = Date.today

    league_ids = League.all.pluck(:ss_id)
    Sofascore::Client.fetch_events(today.to_formatted_s).select do |event|
      event_date = Date.parse(Time.at(event['startTimestamp']).to_s)
      event_date == today && league_ids.include?(event['tournament']['uniqueTournament']['id'])
    end
  end

  def self.find_matching(search)
    team = Team.playing_today.max_by { |t| t.matching_score search }
    matches = team.matching_score(search) >= Matching::MIN_MATCH_SCORE

    Event.for_team team if matches
  end

  def self.fetch_incidents(event)
    Resque.logger.info "[Incident Fetch] Fetching incidents for #{event.slug}"

    before_start_time = Time.now.to_i < event.start_timestamp

    if before_start_time
      Resque.logger.info "[Incident Fetch] Event #{event.slug} hasn't started yet"
      return
    end

    # TODO: Don't fetch incidents when the event has ended

    incidents = Sofascore::Client.fetch_incidents(event.ss_id)

    Resque.logger.info "[Incident Fetch] Found #{incidents.count} new incidents" if incidents

    incidents&.each do |incident|
      next if event.incidents.find_by(ss_id: incident['id'])

      incident_attrs = Incident.from_hash incident

      if event.monitored? && incident_attrs[:incident_type] == Incidents::Types::GOAL
        incident_attrs[:searching_since] = Time.now
      end

      event.incidents.create(incident_attrs)
    end
  end

  def self.fetch_day_events
    date = Date.today.to_s

    # Filter out events with a different date or from a league we're not
    # following
    Resque.logger.info("[EventManager] Fetching day events for #{date}")
    events = Sofascore::Client.fetch_events(date).select do |event_data|
      next unless Date.today == Time.at(event_data['startTimestamp']).to_date

      next unless League.find_by(ss_id: event_data['tournament']['uniqueTournament']['id'])

      true
    end
    Resque.logger.info("[EventManager] Found #{events.count} events in followed leagues")

    # Create event records for filtered events
    events.map do |event_data|
      Resque.logger.info("[EventManager] Importing #{event_data['slug']}")
      Event.from_hash(event_data)
    end
  end
end
