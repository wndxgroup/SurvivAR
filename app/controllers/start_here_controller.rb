class StartHereController < UIViewController
  def loadView
    @layout = StartHereLayout.new
    self.view = @layout.view
    @layout.add_constraints

    @start_button = @layout.get(:start_button)
    @username = @layout.get(:username)
  end

  def viewDidLoad
    @start_button.addTarget(self, action: 'create_account', forControlEvents: UIControlEventTouchUpInside)
  end

  def create_account
    return if @username.text == ''

    # Save info to device
    # Push user to Menu Screen
  end
end