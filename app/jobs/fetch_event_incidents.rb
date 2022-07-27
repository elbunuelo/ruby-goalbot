class FetchEventIncidents
  @queue = :incidents

  def self.perform(event_id)
    Resque.logger.info('[FetchEventIncidents] Performing FetchEventIncidents')
    event = Event.find(event_id)
    Resque.logger.info("[FetchEventIncidents] Fetching Incidents for #{event.slug}")
    EventManager.fetch_incidents(event)
  end
end
