require 'redd'

MAX_SUBMISSIONS = 50
class Reddit
  @last_seen = nil
  def self.process_submissions
    login unless @session

    loop do
      Rails.logger.info '[Reddit] Fetching new submissions from reddit'
      Rails.logger.info("[Reddit] Last submission seen '#{@last_seen.title}'") if @last_seen

      retrieved_last_seen = @session.from_url(@last_seen.url) if @last_seen
      if !retrieved_last_seen || !retrieved_last_seen.is_robot_indexable?
        @last_seen = nil
        Rails.logger.info('[Reddit] Last seen submission not found, resetting')
      end

      @last_seen = nil if @last_seen && @session.from_url(@last_seen.url).deleted?
      submissions = @session.subreddit('soccer').new(before: @last_seen&.name || '')

      submissions.each_with_index do |submission, index|
        break if index == MAX_SUBMISSIONS

        if index.zero?
          @last_seen = submission
          Rails.logger.info "[Reddit] Recording last seen submission '#{@last_seen.title}'"
        end

        yield submission
      end

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
