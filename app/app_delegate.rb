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
    navigationController = UINavigationController.alloc.initWithRootViewController(rootViewController)
    navigationController.navigationBar.barTintColor = UIColor.alloc.initWithRed(1.0, green: 189.0/255, blue: 74.0/255, alpha: 1.0)
    navigationController.navigationBar.translucent = false
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = navigationController
    @window.makeKeyAndVisible

    true
  end
end
