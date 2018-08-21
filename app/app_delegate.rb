class AppDelegate
  include CDQ, Colors

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    cdq.setup
    rootViewController = begin
      player = Player.first
      player && player.accounts.count > 0 ? menu_controller : create_an_account_controller
    end
    @navigation_controller = UINavigationController.alloc.initWithRootViewController(rootViewController)
    @navigation_controller.navigationBar.barTintColor = orange
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