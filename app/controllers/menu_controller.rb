class MenuController < UIViewController
  include SurvivalTime

  def loadView
    @layout = MenuLayout.new
    self.view = @layout.view
    @layout.add_constraints

    @vision_button = @layout.get(:vision_button)
    @map_button = @layout.get(:map_button)
    @accounts_button = @layout.get(:accounts_button)
  end

  def viewDidLoad
    @vision_button.addTarget(self, action: 'push_user_to_vision', forControlEvents: UIControlEventTouchUpInside)
    @map_button.addTarget(self, action: 'push_user_to_map', forControlEvents: UIControlEventTouchUpInside)
    @accounts_button.addTarget(self, action: 'push_user_to_accounts', forControlEvents: UIControlEventTouchUpInside)
  end

  def didMoveToParentViewController(parent)
    account = Player.first.accounts[Player.first.current_account]
    @layout.get(:username).text = account.username
    @layout.get(:survival_time).text = survival_time(account)
  end

  def push_user_to_vision
    parentViewController.start_vision(self)
  end

  def push_user_to_map
    parentViewController.start_map(self)
  end

  def push_user_to_accounts
    parentViewController.start_accounts_page(self)
  end
end