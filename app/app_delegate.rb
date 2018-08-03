class AppDelegate
  include CDQ

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    cdq.setup
    rootViewController = begin
      player = Player.first
      if player && player.accounts.count > 0
        MenuController.new
      else
        CreateAnAccountController.new
      end
    end
    @navigationController = UINavigationController.alloc.initWithRootViewController(rootViewController)
    @navigationController.navigationBar.barTintColor = UIColor.alloc.initWithRed(1.0, green: 189.0/255, blue: 74.0/255, alpha: 1.0)
    @navigationController.navigationBar.translucent = false
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = @navigationController
    @window.makeKeyAndVisible

    @center = UNUserNotificationCenter.currentNotificationCenter
    true
  end

  def applicationDidBecomeActive(_)
    @center.removeAllPendingNotificationRequests
    @center.removeAllDeliveredNotifications
  end

  def applicationWillResignActive(_)
    current_controller = @navigationController.topViewController
    current_controller.go_to_menu if current_controller.is_a?(ARViewController)
    set_notification(2)
  end

  def set_notification(days)
    @center.requestAuthorizationWithOptions(UNAuthorizationOptionAlert | UNAuthorizationOptionSound,
                                            completionHandler: lambda { |_, _| })
    @center.delegate = self
    content = UNMutableNotificationContent.new
    content.title = 'The battleground awaits! 🔥'
    content.sound = UNNotificationSound.soundNamed('notification.mp3')
    trigger = UNTimeIntervalNotificationTrigger.triggerWithTimeInterval(days , repeats: false)
    notification = UNNotificationRequest.requestWithIdentifier('_', content: content, trigger: trigger)
    @center.addNotificationRequest(notification, withCompletionHandler: lambda { |_| })
  end

  def userNotificationCenter(_, didReceiveNotificationResponse: _, withCompletionHandler: completion_handler)
    @navigationController.setViewControllers([MenuController.new], animated: false)
    completion_handler.call
  end
end
