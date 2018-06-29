module SurvivalTime
  def survival_time(account)
    [account.days,
     account.hours,
     account.minutes,
     account.seconds].map {|time|
      time_str = time.to_s
      '0' << time_str if time_str.length == 1
    }.join(':')
  end
end