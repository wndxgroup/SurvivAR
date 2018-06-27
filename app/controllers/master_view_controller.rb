class MasterViewController < UIViewController
  def init
    super

    self
  end

  def viewDidLoad
    @start_here_controller = StartHereController.new
    self.addChildViewController(@start_here_controller)
    prepare_start_here_screen
  end

  def prepare_start_here_screen
    self.view.addSubview(@start_here_controller.view)
    @start_here_controller.view.translatesAutoresizingMaskIntoConstraints = false
    @start_here_controller.view.leftAnchor.constraintEqualToAnchor(view.safeAreaLayoutGuide.leftAnchor).active = true
    @start_here_controller.view.rightAnchor.constraintEqualToAnchor(view.safeAreaLayoutGuide.rightAnchor).active = true
    @start_here_controller.view.topAnchor.constraintEqualToAnchor(view.safeAreaLayoutGuide.topAnchor).active = true
    @start_here_controller.view.bottomAnchor.constraintEqualToAnchor(view.safeAreaLayoutGuide.bottomAnchor).active = true
    @start_here_controller.didMoveToParentViewController(self)
  end
end