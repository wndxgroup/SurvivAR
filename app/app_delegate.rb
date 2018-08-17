class AppDelegate
  include CDQ

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    cdq.setup

    audio_session = AVAudioSession.sharedInstance
    audio_session.setCategory(AVAudioSessionCategoryPlayAndRecord,
                              withOptions: AVAudioSessionCategoryOptionDefaultToSpeaker,
                              error: nil)
    audio_session.setActive(true, withOptions: AVAudioSessionCategoryOptionDefaultToSpeaker, error: nil)

    rootViewController = begin
      player = Player.first
      player && player.accounts.count > 0 ? menu_controller : create_an_account_controller
    end
    @navigation_controller = UINavigationController.alloc.initWithRootViewController(rootViewController)
    navigation_bar_color = UIColor.alloc.initWithRed(1.0, green: 189.0/255, blue: 74.0/255, alpha: 1.0)
    @navigation_controller.navigationBar.barTintColor = navigation_bar_color
    @navigation_controller.navigationBar.translucent = false
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = @navigation_controller
    @window.makeKeyAndVisible
    @center = UNUserNotificationCenter.currentNotificationCenter
    true
  end

  def accounts_list_controller
    @accounts_list_controller ||= AccountsListController.new
  end

  def battleground_controller
    @battleground_controller ||= BattlegroundController.new
  end

  def create_an_account_controller
    @create_an_account_controller ||= CreateAnAccountController.new
  end

  def death_controller
    @death_controller ||= DeathController.new
  end

  def leaderboard_controller
    @leaderboard_controller ||= LeaderboardController.new
  end

  def menu_controller
    @menu_controller ||= MenuController.new
  end

  def my_account_controller
    @my_account_controller ||= MyAccountController.new
  end

  def applicationWillResignActive(_)
    current_controller = @navigation_controller.topViewController
    player = Player.first
    account = player.sorted_accounts[player.current_account]
    current_controller.go_to_menu if current_controller.is_a?(BattlegroundController) && account.battling?
    set_notification(2)
  end

  def applicationDidBecomeActive(_)
    @center.removeAllPendingNotificationRequests
    @center.removeAllDeliveredNotifications
  end

  def set_notification(days)
    @center.removeAllPendingNotificationRequests
    @center.requestAuthorizationWithOptions(UNAuthorizationOptionAlert | UNAuthorizationOptionSound,
                                            completionHandler: lambda { |_, _| })
    @center.delegate = self
    content = UNMutableNotificationContent.new
    content.title = 'The battleground awaits! 🔥'
    content.sound = UNNotificationSound.soundNamed('notification.mp3')
    trigger = UNTimeIntervalNotificationTrigger.triggerWithTimeInterval(days * 60 * 60 * 24, repeats: false)
    notification = UNNotificationRequest.requestWithIdentifier('_', content: content, trigger: trigger)
    @center.addNotificationRequest(notification, withCompletionHandler: lambda { |_| })
  end

  def userNotificationCenter(_, didReceiveNotificationResponse: _, withCompletionHandler: completion_handler)
    @navigation_controller.setViewControllers([menu_controller], animated: false)
    completion_handler.call
  end
end