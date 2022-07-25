require 'redd'

class Reddit
  def self.process_submissions(&block)
    login unless @session

    @session.subreddit('soccer').new.stream(&block)
  end

  def self.login
    @session = Redd.it(
      user_agent: ENV['BOT_USER_AGENT'],
      client_id: ENV['REDDIT_CLIENT_ID'],
      secret: ENV['REDDIT_SECRET']
    )
  end
end
