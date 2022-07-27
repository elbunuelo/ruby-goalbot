module Goal
  GOAL_REGEX = /^(?<category>\[[\w\s]+\])?\s*(?<home_team>[^\[(]+)\s+(?<home_goals>[\[(]?\d+[)\]]?)-\s*(?<away_goals>[\[(]?\d+[\])]?)\s*(?<away_team>[^\[(]+)\s*(?<aggregate>\[[^\]]+\])?\s+(?<rest>.+)/
  SCORE_REGEX = /^[\[(]\d+[\])]$/

  HOME_TEAM = 1
  HOME_SCORE = 2
  AWAY_SCORE = 3
  AWAY_TEAM  = 4
end
