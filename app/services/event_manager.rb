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
    Rails.logger.debug "[Incident Fetch] Fetching incidents for #{event.slug}"

    before_start_time = Time.now.to_i < event.start_timestamp

    if before_start_time
      Rails.logger.debug "[Incident Fetch] Event #{event.slug} hasn't started yet"
      return
    end

    # TODO: Don't fetch incidents when the event has ended

    incidents = Sofascore::Client.fetch_incidents(event.ss_id)&.select do |incident|
      incident_id = incident.fetch('id', 0)
      !event.last_incident_seen || incident_id > event.last_incident_seen
    end

    Rails.logger.debug "[Incident Fetch] Found #{incidents.count} new incidents"

    incidents&.each do |incident|
      player_name = incident.fetch('player_name', nil) || incident.fetch('player', {}).fetch('name', nil)

      incident_attrs = {
        player_name: player_name,
        reason: incident.fetch('reason', nil),
        incident_class: incident.fetch('incidentClass', nil),
        incident_type: incident.fetch('incidentType', nil),
        time: incident.fetch('time', nil),
        ss_id: incident.fetch('id', nil),
        is_home: incident.fetch('isHome', nil),
        text: incident.fetch('text', nil),
        home_score: incident.fetch('homeScore', nil),
        away_score: incident.fetch('awayScore', nil),
        added_time: incident.fetch('addedTime', nil),
        player_in: incident.fetch('playerIn', {}).fetch('name', nil),
        player_out: incident.fetch('playerOut', {}).fetch('name', nil),
        length: incident.fetch('length', nil),
        description: incident.fetch('description', nil)
      }

      if event.monitored? && incident_attrs[:incident_type] == Incidents::Types::GOAL
        incident_attrs[:searching_since] = Time.now
      end

      event.incidents.create(incident_attrs)
    end

    event.last_incident_seen = event.incidents.maximum(:ss_id)
    event.save
  end

  def self.fetch_day_events
    date = Date.today.to_s

    # Filter out events with a different date or from a league we're not
    # following
    events = Sofascore::Client.fetch_events(date).select do |event_data|
      next unless Date.today == Time.at(event_data['startTimestamp']).to_date

      next unless League.find_by(ss_id: event_data['tournament']['uniqueTournament']['id'])

      true
    end

    # Create event records for filtered events
    events.map do |event_data|
      home_team_data = event_data['homeTeam']
      home_team = Team.create_or_find_by!(
        {
          ss_id: home_team_data['id'],
          slug: home_team_data['slug'],
          short_name: home_team_data['shortName']
        }
      )

      away_team_data = event_data['awayTeam']
      away_team = Team.create_or_find_by!(
        {
          ss_id: away_team_data['id'],
          slug: away_team_data['slug'],
          short_name: away_team_data['shortName']
        }
      )

      Event.create_or_find_by!(
        {
          start_timestamp: event_data['startTimestamp'],
          previous_leg_ss_id: event_data.fetch('previousLegEventId', nil),
          ss_id: event_data['id'],
          home_team: home_team,
          away_team: away_team,
          date: Date.today
        }
      )
    end
  end
end
