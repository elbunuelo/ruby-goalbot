class Incident < ApplicationRecord
  belongs_to :event

  after_create :maybe_cancel_incident_fetch
  after_create :maybe_schedule_search_cancellation

  scope :goals_pending_link, lambda {
                               where(incident_type: Incidents::Types::GOAL, search_suspended: false, video_url: nil)
                             }

  scope :default, -> { order(:time) }

  def teams_match(goal)
    home_score = event.home_team.matching_score(goal[:home_team])
    away_score = event.away_team.matching_score(goal[:away_team])
    Rails.logger.info "[Incident] Comparing teams #{event.home_team.name} #{goal[:home_team]} (#{home_score}) and #{event.away_team.name} #{goal[:away_team]} (#{away_score})"

    home_score >= Matching::MIN_MATCH_SCORE && away_score >= Matching::MIN_MATCH_SCORE
  end

  def self.for_goal(goal_info)
    Incident.goals_pending_link.where(
      {
        # is_home: goal_info[:is_home],
        home_score: goal_info[:home_score],
        away_score: goal_info[:away_score]
      }
    )
  end

  private

  def maybe_cancel_incident_fetch
    return unless incident_type == Incidents::Types::PERIOD && text == 'FT'

    Resque.remove_schedule(event.schedule_name)
  end

  def maybe_schedule_search_cancellation
    return unless incident_type == Incidents::Types::GOAL

    Rake.enqueue_in(Incidents::MAX_SEARCH_TIME, CancelGoalSearch, id)
  end

  def self.from_hash(incident_data)
    player_name = incident_data.fetch('player_name', nil) || incident_data.fetch('player', {}).fetch('name', nil)

    {
      player_name: player_name,
      reason: incident_data.fetch('reason', nil),
      incident_class: incident_data.fetch('incidentClass', nil),
      incident_type: incident_data.fetch('incidentType', nil),
      time: incident_data.fetch('time', nil),
      ss_id: incident_data.fetch('id', nil),
      is_home: incident_data.fetch('isHome', nil),
      text: incident_data.fetch('text', nil),
      home_score: incident_data.fetch('homeScore', nil),
      away_score: incident_data.fetch('awayScore', nil),
      added_time: incident_data.fetch('addedTime', nil),
      player_in: incident_data.fetch('playerIn', {}).fetch('name', nil),
      player_out: incident_data.fetch('playerOut', {}).fetch('name', nil),
      length: incident_data.fetch('length', nil),
      description: incident_data.fetch('description', nil)
    }
  end
end
