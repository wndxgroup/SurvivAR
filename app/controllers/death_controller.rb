class DeathController < UIViewController
  include SurvivalTime

  def loadView
    @layout = DeathLayout.new
    navigationController.setNavigationBarHidden(false, animated: true)
    self.title = 'You Died'
    self.view = @layout.view
    @layout.add_constraints
  end

  def viewDidLoad
    cdq.setup
    player = Player.first
    account = player.sorted_accounts[player.current_account]
    @layout.get(:name_field).text = "#{account.username} survived for"
    @layout.get(:duration).text = survival_time(account)
    @layout.get(:accounts_button).addTarget(self,
                                            action: 'push_user_to_accounts',
                                            forControlEvents: UIControlEventTouchUpInside)
    player.current_account = nil
    cdq.save
  end

  def push_user_to_accounts
    if navigationController.viewControllers.count == 1
      navigationController.setViewControllers([AccountsListController.new], animated: true)
    else
      navigationController.popViewControllerAnimated(true)
    end
  end
end