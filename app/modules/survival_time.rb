module SurvivalTime
  def survival_time(account)
    [account.hours,
     account.minutes,
     account.seconds.floor].map {|time|
      time_str = time.to_s
      time_str = '0' + time_str if time_str.length == 1
      time_str
    }.join(':')
  end

  def secs_per_min; 60; end
  def secs_per_hour; secs_per_min * 60; end
  def secs_per_day; secs_per_hour * 24; end

  def calculate_survival_time_increase(account)
    current_time = Time.now # This line causes the memory build up. Assigning a string or hash does the same
    secs = (current_time - account.start_time)
    account.start_time = current_time
    mins = hours = 0

    if secs >= secs_per_hour
      hours = secs / secs_per_hour
      secs = secs - (hours * secs_per_hour)
    end

    if secs >= secs_per_min
      mins = secs / secs_per_min
      secs = secs - (mins * secs_per_min)
    end

    increase_survival_time(account, hours: hours, mins: mins, secs: secs)
  end

  def increase_survival_time(account, hours: hours, mins: mins, secs: secs)
    account.seconds += secs
    if account.seconds >= 60
      account.minutes += 1
      account.seconds -= 60
    end

    account.minutes += mins
    if account.minutes >= 60
      account.hours += 1
      account.minutes -= 60
    end

    account.hours += hours
  end
end