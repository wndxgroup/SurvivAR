class MenuController < UIViewController
  def loadView
    @layout = MenuLayout.new
    self.view = @layout.view
    @layout.add_constraints

    account = Player.first.accounts[Player.first.current_account]
    @layout.get(:username).text = account.username
    @layout.get(:survival_time).text = survival_time(account)
  end

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