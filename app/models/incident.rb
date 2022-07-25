class Incident < ApplicationRecord
  belongs_to :event

  after_create :maybe_cancel_incident_fetch

  scope :goals_pending_link, lambda {
                               where(incident_type: Incidents::Types::GOAL, search_suspended: false, video_url: nil)
                             }

  def teams_match(goal)
    home_score = event.home_team.matching_score(goal[:home_team])
    away_score = event.away_team.matching_score(goal[:away_team])
    Rails.logger.debug "[Incident] Comparing teams #{event.home_team.name} #{goal[:home_team]} (#{home_score}) and #{event.away_team.name} #{goal[:away_team]} (#{away_score})"

    home_score >= Matching::MIN_MATCH_SCORE && away_score >= Matching::MIN_MATCH_SCORE
  end

  def search_time_exceeded?
    return false unless searching_since

    Time.now - searching_since > Incidents::MAX_SEARCH_TIME
  end

  def self.for_goal(goal_info)
    Incident.goals_pending_link.where(
      {
        is_home: goal_info[:is_home],
        home_score: goal_info[:home_score],
        away_score: goal_info[:away_score]
      }
    )
  end

  private

  def maybe_cancel_incident_fetch
    return unless incident_type == Incidents::Type::PERIOD && text = 'FT'

    Resque.remove_schedule(event.schedule_name)
  end
end
