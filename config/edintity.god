RAILS_ROOT = File.dirname(File.dirname(__FILE__))

if RAILS_ROOT.include? "current"
  RAILS_ENV="production"
else
  RAILS_ENV="development" # assumption
end

def generic_monitoring(w, options = {})
  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 10.seconds
      c.running = false
    end
  end

  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = options[:memory_limit]
      c.times = [3, 5] # 3 out of 5 intervals
    end

    restart.condition(:cpu_usage) do |c|
      c.above = options[:cpu_limit]
      c.times = 5
    end
  end

  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end

# STARLING
God.watch do |w|


  w.name = "edintity-starling"
  w.group = "edintity"
  w.interval = 60.seconds

  case RAILS_ENV

    when "production"
      port = 15151

    else
      port = 22122 # assuming dev.. from the settings above

  end

  w.start = "starling -d -P #{RAILS_ROOT}/log/starling.pid -q #{RAILS_ROOT}/log/ -p #{port.to_s}"

  w.stop = "kill `cat #{RAILS_ROOT}/log/starling.pid`"
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.pid_file = "#{RAILS_ROOT}/log/starling.pid"

  w.behavior(:clean_pid_file)

  generic_monitoring(w, :cpu_limit => 30.percent, :memory_limit => 20.megabytes)
end

# WORKLING
God.watch do |w|
  script = "cd #{RAILS_ROOT} && RAILS_ENV=#{RAILS_ENV} script/workling_client"
  w.name = "edintity-workling"
  w.group = "edintity"
  w.interval = 60.seconds
  w.start = "#{script} start"
  w.restart = "#{script} restart"
  w.stop = "#{script} stop"
  w.start_grace = 20.seconds
  w.restart_grace = 20.seconds
  w.pid_file = "#{RAILS_ROOT}/log/workling.pid"

  w.behavior(:clean_pid_file)

  generic_monitoring(w, :cpu_limit => 80.percent, :memory_limit => 100.megabytes)
end

