class DeathController < UIViewController
  include Rankings, Recorder

  def loadView
    @layout = DeathLayout.new
    navigationController.setNavigationBarHidden(false, animated: true)
    self.title = 'You Died'
    self.view = @layout.view
    @layout.add_constraints
  end

  def viewDidLoad
    cdq.setup
    @player = Player.first
    @account = @player.sorted_accounts[@player.current_account]
    round = @account.sorted_rounds[-1]

    recorder = RPScreenRecorder.sharedRecorder
    handler = lambda do |previewViewController, error|
      unless error
        @replay_controller = previewViewController
        @replay_controller.previewControllerDelegate = self
      end
    end
    recorder.stopRecordingWithHandler(handler)

    round_stats_container   = @layout.get(:round_stats_container)
    round_stats_kills       = @layout.get(:round_stats_kills)
    round_stats_time        = @layout.get(:round_stats_time)
    round_ranking_container = @layout.get(:round_ranking_container)
    round_ranking_kills     = @layout.get(:round_ranking_kills)
    round_ranking_time      = @layout.get(:round_ranking_time)
    new_round_button        = @layout.get(:new_round)
    leaderboard_button      = @layout.get(:leaderboard)
    my_account_button       = @layout.get(:my_account)
    @replay_button          = @layout.get(:replay)

    determine_kills_rankings
    determine_life_rankings
    kills_ranking = @most_kills.index(round) + 1
    survival_time_ranking = @longest_life.index(round) + 1

    round_stats_kills.text   += "\n#{round.kills}"
    round_stats_time.text    += "\n#{round.survival_time}"
    round_ranking_kills.text += "\n#{kills_ranking} / #{@most_kills.count}"
    round_ranking_time.text  += "\n#{survival_time_ranking} / #{@longest_life.count}"

    round_stats_container.layer.cornerRadius = round_ranking_container.layer.cornerRadius = 10
    round_stats_container.clipsToBounds      = round_ranking_container.clipsToBounds      = true
    leaderboard_button.setTitleColor(UIColor.blackColor, forState: UIControlStateNormal)

    new_round_button  .addTarget(self, action: 'start_new_round',   forControlEvents: UIControlEventTouchUpInside)
    leaderboard_button.addTarget(self, action: 'go_to_leaderboard', forControlEvents: UIControlEventTouchUpInside)
    my_account_button .addTarget(self, action: 'go_to_my_account',  forControlEvents: UIControlEventTouchUpInside)
    @replay_button    .addTarget(self, action: 'show_replay',       forControlEvents: UIControlEventTouchUpInside)
  end

  def show_replay
    unless @replay_controller
      alert = UIAlertController.alertControllerWithTitle('Recording Unavailable',
                                                         message: 'An error occured while trying to replay the recording',
                                                         preferredStyle: UIAlertControllerStyleAlert)
      action = UIAlertAction.actionWithTitle('Ok', style: UIAlertActionStyleDefault, handler: nil)
      alert.addAction(action)
      presentViewController(alert, animated: true, completion: nil)
      hide_replay_button
    else
      presentViewController(@replay_controller, animated: true, completion: nil)
    end
  end

  def start_new_round
    initiate_recording
    app_delegate = UIApplication.sharedApplication.delegate
    menu         = app_delegate.menu_controller
    battleground = app_delegate.battleground_controller
    navigationController.setViewControllers([menu, battleground], animated: true)
  end

  def go_to_leaderboard
    app_delegate = UIApplication.sharedApplication.delegate
    menu         = app_delegate.menu_controller
    leaderboard  = app_delegate.leaderboard_controller
    navigationController.setViewControllers([menu, leaderboard], animated: true)
  end

  def go_to_my_account
    app_delegate   = UIApplication.sharedApplication.delegate
    menu           = app_delegate.menu_controller
    accounts_list  = app_delegate.accounts_list_controller
    my_account     = app_delegate.my_account_controller
    account_number = @player.sorted_accounts.index(@account)
    my_account.set_account(account_number)
    navigationController.setViewControllers([menu, accounts_list, my_account], animated: true)
  end

  def hide_replay_button
    @replay_button.setImage(nil, forState: UIControlStateNormal)
    @layout.get(:logo).topAnchor.constraintEqualToAnchor(@replay_button.topAnchor).active = true
  end

  def previewControllerDidFinish(previewController)
    previewController.dismissViewControllerAnimated(true, completion: nil)
    hide_replay_button
  end
end