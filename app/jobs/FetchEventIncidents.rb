class EventIncidentsFetcher
  def perform(event)
    EventManager.fetch_incidents(event)
  end
end
