class Subscription < ApplicationRecord
  belongs_to :event

  after_create :schedule_incident_fetch

  private

  def schedule_incident_fetch
    return if Resque.fetch_schedule event.schedule_name

    Resque.set_schedule(
      event.schedule_name,
      {
        class: 'FetchEventIncidents',
        args: event,
        every: ['1m', { first_at: Time.at(event_data['startTimestamp']) }]
      }
    )
  end
end
