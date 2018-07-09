class DeathController < UIViewController
  include SurvivalTime

  def loadView
    @layout = DeathLayout.new
    self.view = @layout.view
    @layout.add_constraints
  end

  def didMoveToParentViewController(_)
    player = Player.first
    account = player.sorted_accounts[player.current_account]
    @layout.get(:name_field).text = "#{account.username} survived for"
    @layout.get(:duration).text = survival_time(account)
    @layout.get(:accounts_button).addTarget(self,
                                            action: 'push_user_to_accounts',
                                            forControlEvents: UIControlEventTouchUpInside)
  end

  def push_user_to_accounts
    parentViewController.start_accounts_page(self)
  end
end