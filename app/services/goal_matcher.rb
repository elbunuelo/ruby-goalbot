# This is the usual format for a goal submission is as follows:
#
#  Home Team Score   Away Team            Player Part             Qualifier
#  ________  ___  __________________   __________________   ________________________
# |        ||   ||                  | |                  | |                        |
#  Banfield  1-0  Argentinos Juniors - Emanuel Coronel 39' (great double nutmeg goal)
#                                   |_|
#                                 Separator
#
# A variation includes a category at the begining of the submission:
#
#    Category
#  _____________
# |             |
# [Club Friendly] Arsenal [2] - 0 Everton - Bukayo Saka 36'

# The qualifier appears at the end of the title as text within parentheses
QUALIFIER_REGEX = '\\s*\\([^\\)]+\\)$'.freeze

# The score for either of the teams can appear as-is, or within either brackets
# or parentheses
SINGLE_SCORE_STR = ''.freeze

# The current score of the match appears as two scores separated by a hyphen
# and it may or may not have spaces between either score and the hyphen.
# The home_score and away_score values contain just the value of the scores,
# while full_home_score and away_home_score may include the indicators who
# scored.
SCORE_REGEX = '(?<full_home_score>[\\[(]?(?<home_score>\\d+)[\\])]?)\\s*-\\s*(?<full_away_score>[\\[(]?(?<away_score>\\d+)[\\])]?)'.freeze

# The category appears at the begining of the string as text within brackets
CATEGORY_REGEX = '^(?<category>\\[[^\\]]+\\])'.freeze

# Sometimes the aggregate of a two leg-match is shown after the away team name
# within brackets:
#
# Tirana 0-2 Dudelange [0-3 on agg.] - Dejvid Sinani 61'
#
# The team regex matches anything but an open bracket to make sure that we
# don't capture the aggregate as part of the submission.
TEAM_REGEX = '(?<team>[^\\[\\(]+)'.freeze
FIRST_PART_REGEX = "#{CATEGORY_REGEX}?\\s*#{TEAM_REGEX}".freeze

class GoalMatcher
  def self.check(title)
    Rails.logger.info "[GoalMatcher] Checking submission for goal format #{title}"
    # Goal may have a qualifier like great goal or the league:
    #
    # Lusitano GC 0-6 FC Porto - Hernâni 90' (Scorpion Goal - Taça de Portugal)
    # Legia Warszawa 0-1 Celtic - Reo Hatate 20' (King's Party)
    # Club America 0-1 Manchester City - Kevin De Bruyne 30’ (great goal!)
    # Senegal 1-1 Egypt - Penalty Shootout (3-1)
    #
    # We remove it to avoid confusion when splitting off the last part but it's
    # not considered essential to identify a goal.
    #
    # Most of the time, it will show up as text within parentheses at the end of
    # the submission.
    qualifier_match = title.match QUALIFIER_REGEX
    title.sub!(qualifier_match.to_s, '') if qualifier_match
    Rails.logger.info "[GoalMatcher] Found qualifier for the submission #{qualifier_match}"

    # The score is always present in a goal title this is the base by which we
    # identify the different parts of the submission title.
    #
    # Most of the time it will show up as <home_score>-<away_score>. With the
    # score that changed in brackets or parentheses e.g. [1]-0 or (2)-1. But
    # there are also instances where it shows up without them so we can't
    # use the lack of either to rule out non-submissions.
    #
    # There are some occasions in which the score is shown as
    # <home_team> <home_score> - <away_team> <away_score>
    # These are not considered valid at the moment.
    #
    # We assume that the goal will be the first instance that matches the regular
    # expression
    score_match = title.match SCORE_REGEX

    raise Errors::NoGoalMatch, title unless score_match

    Rails.logger.info "[GoalMatcher] Found score match #{score_match}"
    full_home_score = score_match[:full_home_score]
    home_score = score_match[:home_score]
    full_away_score = score_match[:full_away_score]
    away_score = score_match[:away_score]

    # is_home indicates if the home team is the one that scored, it can take
    # three values:
    # - nil: there's no indication of who scored from the title.
    # - true: The home team scored, i.e the home score is surrounded by
    #         parentheses or brackets.
    # - false: The awya team scored, i.e the away score is surrounded by
    #         parentheses or brackets.
    is_home = nil
    is_home = true if home_score != full_home_score
    is_home = false if away_score != full_away_score
    Rails.logger.info '[GoalMatcher] Submission contains scorer info.' unless is_home.nil?

    # Match the home team
    # Similarly to the qualifier, the submission can have a category prefixing
    # it. When it is present, a category usually corresponds to the tournament
    # the match belongs to.
    #
    # [Copa Argentina] Barracas Central 0-2 River Plate - Agustín Palavecino 66' great goal
    # [Club Friendly] Arsenal [2] - 0 Everton - Bukayo Saka 36'
    #
    # Anything between the category and the score is assumed to be the home team
    # name.
    pre = score_match.pre_match.strip
    first_part_match = pre.match FIRST_PART_REGEX
    raise Errors::NoGoalMatch, title unless first_part_match

    home_team = first_part_match[:team]
    Rails.logger.info "[GoalMatcher] Found home team: #{home_team}"

    # Remove player and time
    # After the teams and scores, there is a section that indicates the
    # name of the player who scored an the time.
    #
    # The separator is somewhat inconsistent, but most times it will be either
    # a hyphen (-), a double hyphen (--), a colon (:) or a pipe (|).
    # In order to avoid confusions, for example where there is a penalty
    # shootout, the player's name has a hyphen or for some other reason, a hyphen
    # appers after the away team name, we check that there's at least one space
    # after the separator.
    #
    # France W 2-0 Italy W - Marie-Antoinette Katoto 12'
    # Shakhtar Donetsk 0-6 Borussia Mönchengladbach - Alassane Pléa 78' hat-trick
    # Jagiellonia Białystok 0-1 Widzew Łódź - Bartłomiej Pawłowski free-kick 72' great goal (Polish Ekstraklasa)
    post = score_match.post_match.strip
    player_part_separator_str = '(--?|:|\\|)\\s+'
    player_part_separator_regexp = Regexp.new(player_part_separator_str)
    player_part_separator = post.match(player_part_separator_regexp).to_s

    # The absence of a separator most likely indicates that the submission is not
    # actually a goal.
    raise Errors::NoGoalMatch, title unless player_part_separator

    Rails.logger.info "[GoalMatcher] Found player part separator: #{player_part_separator}"

    # After finding out what the separator is, we can use it to remove the player
    # and time part from the submission, we don't really care about it. We're
    # left with the away team name.
    away_team_part = post.split(player_part_separator)[0].strip

    away_team_match = away_team_part.match TEAM_REGEX
    away_team = away_team_match.named_captures['team']
    Rails.logger.info "[GoalMatcher] Found away team: #{away_team}"

    {
      home_team: home_team,
      home_score: home_score,
      away_team: away_team,
      away_score: away_score,
      is_home: is_home
    }
  end
end
