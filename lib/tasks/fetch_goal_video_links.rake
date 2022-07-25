task fetch_goal_video_links: :environment do
  def match_goal(title)
    matches = title.match(Goal::GOAL_REGEX)
    return nil unless matches

    Rails.logger.debug 'Submission appears to be a goal. Checking score format'

    captures = matches.captures
    home_team_scored = captures[Goal::HOME_SCORE].match?(Goal::SCORE_REGEX)
    away_team_scored = captures[Goal::AWAY_SCORE].match?(Goal::SCORE_REGEX)

    if home_team_scored || away_team_scored
      Rails.logger.debug 'Score format matches, assembling goal'
      home_score = captures[Goal::HOME_SCORE]
      home_score = home_score[1..-1] if home_team_scored
      away_score = captures[Goal::AWAY_SCORE]
      away_score = away_score[1..-1] if away_team_scored

      {
        home_team: captures[Goal::HOME_TEAM],
        away_team: captures[Goal::AWAY_TEAM],
        home_score: home_score.to_i,
        away_score: away_score.to_i,
        is_home: home_team_scored
      }
    end
  end

  Reddit.process_submissions do |submission|
    Rails.logger.debug "Processing submission -- #{submission.title}"
    goal = match_goal submission.title
    next unless goal

    Incident.for_goal(goal).each do |incident|
      if incident.teams_match(goal)
        Rails.logger.debug "Goal video found for #{incident.event.home_team.name} #{incident.home_score} - #{incident.away_score} #{incident.event.away_team.name} --  #{submission.url}"
        incident.video_url = submission.url
        incident.save
      elsif incident.search_time_exceeded?
        Rails.logger.debug "Search time exceeded for #{incident.event.home_team.name} #{incident.home_score} - #{incident.away_score} #{incident.event.away_team.name}"
        incident.search_suspended = true
        incident.save
      end
    end
  end
end
