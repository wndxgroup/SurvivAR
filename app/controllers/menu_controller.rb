class MenuController < UIViewController
  def loadView
    @layout = MenuLayout.new
    self.view = @layout.view
    @layout.add_constraints

    account = Player.first.accounts[Player.first.current_account]
    @layout.get(:username).text = account.username
    @layout.get(:survival_time).text = survival_time(account)

    @vision_button = @layout.get(:vision_button)
    @map_button = @layout.get(:map_button)
  end

  def viewDidLoad
    @vision_button.addTarget(self, action: 'push_user_to_vision', forControlEvents: UIControlEventTouchUpInside)
    @map_button.addTarget(self, action: 'push_user_to_map', forControlEvents: UIControlEventTouchUpInside)
  end

  def push_user_to_vision
    parentViewController.start_vision(self)
  end

  def push_user_to_map
    parentViewController.start_map(self)
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