class Event < ApplicationRecord
  belongs_to :home_team, class_name: 'Team'
  belongs_to :away_team, class_name: 'Team'

  has_many :incidents
  has_many :subscriptions

  scope :todays_events, -> { where(date: Date.today) }

  def monitored?
    subscriptions.exists?
  end

  def self.for_team(team)
    Event.todays_events.where('home_team_id = ? OR away_team_id = ?', team.id, team.id).first
  end

  def schedule_incident_fetch
    config
    Resque.set_schedule(
      slug,
      {
        class: 'EventIncidentsFetcher',
        args: self,
        every: '1m'
      }
    )
  end
end
