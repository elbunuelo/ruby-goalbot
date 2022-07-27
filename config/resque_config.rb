require 'resque' # include resque so we can configure it
Resque.redis = "localhost:6379" # tell Resque where redis lives

require 'resque-scheduler'
require 'resque/scheduler/server'
