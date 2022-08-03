require 'redd'

class Reddit
  def self.process_submissions(&block)
    login unless @session

    @session.subreddit('soccer').new.stream(&block)
  end

  def self.login
    @session = Redd.it(
      user_agent: configatron.reddit.user_agent,
      client_id: configatron.reddit.client_id,
      secret: configatron.reddit.secret
    )
  end
end
