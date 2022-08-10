goal-links: bin/rake fetch_goal_video_links
resque-scheduler: bin/rake resque:scheduler
resque: QUEUE=incidents bin/rake resque:work
rails: bin/rails s -p 5300
rails-logs: tail -f ./log/development.log
resque-logs: tail -f ./log/development_resque.log
css: yarn build:css --watch
