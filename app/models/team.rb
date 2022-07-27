include Amatch

class Team < ApplicationRecord
  has_many :home_events, class_name: 'Event', foreign_key: :home_team_id
  has_many :away_events, class_name: 'Event', foreign_key: :away_team_id

  scope :playing_today, lambda {
                          joins('LEFT JOIN events ON (events.home_team_id = teams.id OR events.away_team_id = teams.id)').where('events.date = ?', Date.today)
                        }

  def matching_score(search)
    slug.pair_distance_similar search.downcase
  end

  def self.from_hash(team_data)
    team = Team.find_by(slug: team_data['slug'])

    team || create!(
      {
        ss_id: team_data['id'],
        slug: team_data['slug'],
        name: team_data['name'],
        short_name: team_data['shortName']
      }
    )
  end
end
