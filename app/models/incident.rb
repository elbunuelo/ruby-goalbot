class Incident < ApplicationRecord
  belongs_to :event

  before_create :maybe_set_searching_since
  after_create :maybe_schedule_search_cancellation
  after_update :maybe_send_subscription_messages

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

  def video_message
    message = event.home_team.name
    message += ' ⚽' if is_home
    message += " #{home_score} - #{away_score}"
    message += ' ⚽' unless is_home
    message + " #{event.away_team.name} -- #{video_url}"
  end

  private

  def maybe_set_searching_since
    return unless incident_type == Incidents::Types::GOAL
    return unless event.monitored?

    searching_since = Time.now
  end

  def maybe_schedule_search_cancellation
    return unless incident_type == Incidents::Types::GOAL

    Resque.enqueue_in(Incidents::MAX_SEARCH_TIME, CancelGoalSearch, id)
  end

  def maybe_send_subscription_messages
    return if notifictions_sent
    return unless incident_type == Incidents::Types::GOAL
    return unless video_url

    event.subscriptions.each do |subscription|
      next unless subscription.conversation_id.present?

      Rails.logger.info('[Incident] Sending http request to bot')
      response = HTTParty.post(
        configatron.hangouts.callback_url,
        {
          body: { sendto: subscription.conversation_id, key: configatron.hangouts.api_key,
                  content: video_message }.to_json,
          headers: { 'Content-Type' => 'application/json' },
          verify: false
        }
      )
      Rails.logger.info("[Incident] Response received #{response.code} - #{response.parsed_response}")
    end

    self.notifications_sent = true
    save
  end

  def self.from_hash(incident_data)
    incident = find_by(ss_id: incident_data['id'])

    player_name = incident_data.fetch('player_name', nil) || incident_data.fetch('player', {}).fetch('name', nil)

    event = incident_data.delete(:event)
    incident || event.incidents.create!(
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
    )
  end
end
