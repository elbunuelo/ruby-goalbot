class Event < ApplicationRecord
  belongs_to :home_team, class_name: 'Team'
  belongs_to :away_team, class_name: 'Team'

  has_many :incidents, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  scope :todays_events, -> { where(date: Date.today) }

  def monitored?
    subscriptions.exists?
  end

  def schedule_name
    "#{slug}-#{date}"
  end

  def self.for_team(team)
    Event.todays_events.where('home_team_id = ? OR away_team_id = ?', team.id, team.id).first
  end

  def self.from_hash(event_data)
    event =  Event.find_by(slug: event_data['slug'])

    event || create!(
      {
        start_timestamp: event_data['startTimestamp'],
        previous_leg_ss_id: event_data.fetch('previousLegEventId', nil),
        ss_id: event_data['id'],
        slug: event_data['slug'],
        home_team: Team.from_hash(event_data['homeTeam']),
        away_team: Team.from_hash(event_data['awayTeam']),
        date: Date.today
      }
    )
  end
end
