class MasterViewController < UIViewController
  attr_accessor :menu_controller

  def viewDidLoad
    @start_here_controller = StartHereController.new
    @menu_controller = MenuController.new
    addChildViewController(@start_here_controller)
    addChildViewController(@menu_controller)
    if Player.count > 0
      set_controller(@menu_controller, from: nil)
    else
      set_controller(@start_here_controller, from: nil)
    end
  end

  def set_controller(new_controller, from: old_controller)
    if old_controller
      old_controller.willMoveToParentViewController(nil)
      old_controller.view.removeFromSuperview
    end
    self.view.addSubview(new_controller.view)
    new_controller.view.translatesAutoresizingMaskIntoConstraints = false
    new_controller.view.leftAnchor.constraintEqualToAnchor(view.safeAreaLayoutGuide.leftAnchor).active = true
    new_controller.view.rightAnchor.constraintEqualToAnchor(view.safeAreaLayoutGuide.rightAnchor).active = true
    new_controller.view.topAnchor.constraintEqualToAnchor(view.safeAreaLayoutGuide.topAnchor).active = true
    new_controller.view.bottomAnchor.constraintEqualToAnchor(view.safeAreaLayoutGuide.bottomAnchor).active = true
    new_controller.didMoveToParentViewController(self)
  end
end