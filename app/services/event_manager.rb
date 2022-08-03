class EventManager
  def self.find_matching(search)
    team = Team.search search

    event = Api::Client.next_event team
    raise Errors.EventNotFound, "No Events for #{search} found." unless event

    Rails.logger.info("Found event #{event_hash['slug']}")

    next_event if next_event.date == Date.today
  end

  def self.fetch_incidents(event)
    Resque.logger.info "[Incident Fetch] Fetching incidents for #{event.slug}"

    before_start_time = Time.now.to_i < event.start_timestamp

    if before_start_time
      Resque.logger.info "[Incident Fetch] Event #{event.slug} hasn't started yet"
      return
    end
    incidents = Api::Client.fetch_incidents(event.ss_id)

    Resque.logger.info "[Incident Fetch] Found #{incidents.count} incidents" if incidents

    incidents&.each do |incident|
      if incident.incident_type === Incidents::Types::PERIOD && incident.text == 'FT'
        Resque.remove_schedule(event.schedule_name)
      end

      next if event.incidents.find_by(ss_id: incident['id'])

      Incident.from_hash incident
    end
  end
end
