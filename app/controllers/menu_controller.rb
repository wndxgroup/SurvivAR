class MenuController < UIViewController
  include Recorder

  def loadView
    self.title = 'Menu'
    layout = MenuLayout.new
    self.view = layout.view
    layout.add_constraints

    @battleground = layout.get(:battleground_button)
    @leaderboard  = layout.get(:leaderboard_button)
    @accounts     = layout.get(:accounts_button)
  end

  def viewDidLoad
    navigationController.setNavigationBarHidden(false, animated: true)
    @battleground.layer.cornerRadius = @accounts.layer.cornerRadius = @leaderboard.layer.cornerRadius = 10
    @battleground.clipsToBounds      = @accounts.clipsToBounds      = @leaderboard.clipsToBounds      = true
    @battleground.addTarget(self, action: 'start_battleground', forControlEvents: UIControlEventTouchUpInside)
    @accounts    .addTarget(self, action: 'show_accounts',      forControlEvents: UIControlEventTouchUpInside)
    @leaderboard .addTarget(self, action: 'show_leaderboard',   forControlEvents: UIControlEventTouchUpInside)
  end

  def start_battleground
    if Player.first.current_account
      initiate_recording
      navigationController.setViewControllers([BattlegroundController.new], animated: true)
    else
      alert = UIAlertController.alertControllerWithTitle('Not Logged In',
                                                         message: 'Log into  an account before starting a battleground',
                                                         preferredStyle: UIAlertControllerStyleAlert)
      action = UIAlertAction.actionWithTitle('Log me in',
                                             style: UIAlertActionStyleDefault,
                                             handler: lambda {|_| show_accounts})
      alert.addAction(action)
      presentViewController(alert, animated: true, completion: nil)
    end
  end

  def show_accounts
    navigationController.pushViewController(AccountsListController.new, animated: true)
  end

  def show_leaderboard
    navigationController.pushViewController(LeaderboardController.new, animated: true)
  end
end