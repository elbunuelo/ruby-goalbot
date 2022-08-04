task fetch_goal_video_links: :environment do
  def match_goal(title)
    GoalMatcher.check title
  rescue Errors::NoGoalMatch
    Rails.logger.info "[GoalVideoLinks] Submission \"#{title}\" does not appear to be a goal."
    nil
  end

  Reddit.process_submissions do |submission|
    next unless submission.link_flair_text == 'Media'

    Rails.logger.info "[GoalVideoLinks] Processing submission -- #{submission.title}"
    goal = match_goal submission.title
    next unless goal

    candidate_incidents = Incident.for_goal(goal)
    Rails.logger.info "[GoalVideoLinks] Found #{candidate_incidents.count} candidates for #{goal[:home_team]} #{goal[:home_score]} - #{goal[:away_score]} #{goal[:away_team]}"
    candidate_incidents.each do |incident|
      Rails.logger.info "[GoalVideoLinks] Checking against #{incident.event.home_team.name} #{incident.home_score} - #{incident.away_score} #{incident.event.away_team.name}"
      next unless incident.teams_match(goal)

      Rails.logger.info "[GoalVideoLinks] Goal video found for #{incident.event.home_team.name} #{incident.home_score} - #{incident.away_score} #{incident.event.away_team.name} --  #{submission.url}"
      incident.video_url = submission.url
      incident.save
    end
  end
end
