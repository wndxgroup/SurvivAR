class CreateAnAccountController < UIViewController
  include CDQ
  include Survival

  def loadView
    @layout = StartHereLayout.new
    self.view = @layout.view
    @layout.add_constraints

    @start_button = @layout.get(:start_button)
    @username_field = @layout.get(:username)
    @username_field.delegate = self
  end

  def viewDidLoad
    @start_button.addTarget(self, action: 'create_account', forControlEvents: UIControlEventTouchUpInside)
  end

  def create_account
    @username = @username_field.text
    @username_field.text = ''
    return if @username == '' || username_already_exists(player = Player.first)
    @current_account = player.accounts.create(username: @username, created_on: Time.now)
    player.current_account = player.accounts.count - 1
    cdq.save
    Dispatch::Queue.new('start survival session').async { @current_account.start_survival_session }
    parentViewController.start_vision(self)
  end

  def didMoveToParentViewController(_)
    @username_field.becomeFirstResponder
  end

  def textFieldShouldReturn(_)
    create_account
  end

  def username_already_exists(player)
    player.accounts.each do |acct|
      if @username == acct.username
        alert = UIAlertController.alertControllerWithTitle('Username Unavailable',
                                                           message: "You already have an account with the username '#{@username}'",
                                                           preferredStyle: UIAlertControllerStyleAlert)
        action = UIAlertAction.actionWithTitle('Try again', style: UIAlertActionStyleDefault, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
        return true
      end
    end
    false
  end
end