require 'redd'

# MAX_SUBMISSIONS = 50
class Reddit
  @last_seen = nil

  def self.submission_removed?(submission)
    Rails.logger.info '[Reddit] Checking submission for removal'
    Rails.logger.info "[Reddit] is_robot_indexable? #{submission.is_robot_indexable?}"
    Rails.logger.info "[Reddit] deleted? #{submission.deleted?}"
    Rails.logger.info "[Reddit] removal_reason #{submission.removal_reason}"
    Rails.logger.info "[Reddit] removed_by_category #{submission.removed_by_category}"
    !submission.is_robot_indexable? || submission.deleted? || submission.removal_reason.present? || submission.removed_by_category == 'deleted'
  end

  def self.process_submissions(&block)
    login unless @session

    loop do
      Rails.logger.info '[Reddit] Fetching new submissions from reddit'

      submissions = @session.subreddit('soccer').new(limit: 15)

      submissions.each(&block)

      sleep configatron.reddit.interval
    end
  end

  def self.login
    Rails.logger.info '[Reddit] Logging into reddit'
    @session = Redd.it(
      user_agent: configatron.reddit.user_agent,
      client_id: configatron.reddit.client_id,
      secret: configatron.reddit.secret
    )
  end
end
