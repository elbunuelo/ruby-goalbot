class Subscription < ApplicationRecord
  belongs_to :event

  # after_create :schedule_incident_fetch
  after_save :schedule_incident_fetch

  private

  def schedule_incident_fetch
    if Resque.fetch_schedule event.schedule_name
      Rails.logger.info("[Subscription] Found schedule for #{event.schedule_name}")
      return
    end

    every = '1m'
    Rails.logger.info("[Subscription] It is #{Time.now}, the event starts at #{Time.at(event.start_timestamp)}")
    if Time.now.to_i < event.start_timestamp
      Rails.logger.info("[Subscription] Fetching will start at #{Time.at(event.start_timestamp)}")
      every = [every, { first_at: Time.at(event.start_timestamp) }]
    end

    Rails.logger.info("[Subscription] Scheduling incident fetch for #{event.schedule_name}")

    schedule = Resque.set_schedule(
      event.schedule_name,
      {
        class: 'FetchEventIncidents',
        args: event.id,
        persist: true,
        every: every
      }
    )

    Rails.logger.info("[Subscription] Created schedule #{schedule.inspect}")
  end
end
