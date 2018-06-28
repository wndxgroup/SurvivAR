class CreateAnAccountController < UIViewController
  include CDQ

  def loadView
    @layout = StartHereLayout.new
    self.view = @layout.view
    @layout.add_constraints

    @start_button = @layout.get(:start_button)
    @username = @layout.get(:username)
    @username.delegate = self
  end

  def viewDidLoad
    @start_button.addTarget(self, action: 'create_account', forControlEvents: UIControlEventTouchUpInside)
  end

  def create_account
    return if @username.text == ''
    Player.first.accounts << Account.create(username: @username.text)
    Player.first.current_account = Player.first.accounts.count - 1
    cdq.save
    push_user_to_menu
  end

  def push_user_to_menu
    parentViewController.set_controller(parentViewController.menu_controller, from: self)
  end

  def textFieldShouldReturn(_)
    create_account
  end
end