class MasterViewController < UIViewController
  def init
    super

    self
  end

  def viewDidLoad
    @start_here_controller = StartHereController.new
    self.addChildViewController(@start_here_controller)
    set_controller(@start_here_controller, from: nil)
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