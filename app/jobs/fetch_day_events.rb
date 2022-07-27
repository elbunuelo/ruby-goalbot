class FetchDayEvents
  @queue = :incidents

  def self.perform
    Resque.logger.info("[FetchDayEvents] Fetching day events for #{Date.today}")
    EventManager.fetch_day_events
  end
end
