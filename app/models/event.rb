class Event < ApplicationRecord
  belongs_to :home_team, class_name: 'Team'
  belongs_to :away_team, class_name: 'Team'

  has_many :incidents, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  def monitored?
    subscriptions.exists?
  end

  def schedule_name
    "#{slug}-#{date}"
  end

  def title
    "#{home_team.name} - #{away_team.name}"
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
        date: Time.at(event_data['startTimestamp']).to_date
      }
    )
  end
end
