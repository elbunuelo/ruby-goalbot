require 'resque' # include resque so we can configure it

require 'resque-scheduler'
require 'resque/scheduler/server'

Resque.redis = 'localhost:6380' # tell Resque where redis lives
puts 'Setting up Redis'
