class MenuController < UIViewController
  include SurvivalTime, Survival

  attr_accessor :queue

  def loadView
    self.title = 'Menu'
    @layout = MenuLayout.new
    self.view = @layout.view
    @layout.add_constraints

    @battleground_button = @layout.get(:battleground_button)
    @leaderboard_button = @layout.get(:leaderboard_button)
    @accounts_button = @layout.get(:accounts_button)
  end

  def viewDidLoad
    navigationController.setNavigationBarHidden(false, animated: true)
    @battleground_button.addTarget(self, action: 'start_battleground', forControlEvents: UIControlEventTouchUpInside)
    @accounts_button    .addTarget(self, action: 'show_accounts',      forControlEvents: UIControlEventTouchUpInside)
    @leaderboard_button .addTarget(self, action: 'show_leaderboard',   forControlEvents: UIControlEventTouchUpInside)
    @battleground_button.layer.cornerRadius = @accounts_button.layer.cornerRadius = @leaderboard_button.layer.cornerRadius = 10
    @battleground_button.clipsToBounds = @accounts_button.clipsToBounds = @leaderboard_button.clipsToBounds = true
  end

  def start_battleground
    if Player.first.current_account
      # play_wave_sound
      navigationController.setViewControllers([ARViewController.new], animated: true)
    else
      alert = UIAlertController.alertControllerWithTitle('Not Logged In',
                                                         message: 'Log in with an account before starting a battleground',
                                                         preferredStyle: UIAlertControllerStyleAlert)
      action = UIAlertAction.actionWithTitle('Log me in', style: UIAlertActionStyleDefault, handler: lambda {|_| show_accounts})
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