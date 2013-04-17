# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

job_type :runner,  "cd :path && ruby script/runner -e development :task :output"

set :output, "log/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 1.minute do
#   runner "Post.test"
# end

# Learn more: http://github.com/javan/whenever
