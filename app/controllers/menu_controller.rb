class MenuController < UIViewController
  include SurvivalTime

  def loadView
    @layout = MenuLayout.new
    self.view = @layout.view
    @layout.add_constraints

    @vision_button   = @layout.get(:vision_button)
    @map_button      = @layout.get(:map_button)
    @accounts_button = @layout.get(:accounts_button)
    @state_button    = @layout.get(:state_button)
  end

  def viewDidLoad
    @vision_button  .addTarget(self, action: 'push_user_to_vision',   forControlEvents: UIControlEventTouchUpInside)
    @map_button     .addTarget(self, action: 'push_user_to_map',      forControlEvents: UIControlEventTouchUpInside)
    @accounts_button.addTarget(self, action: 'push_user_to_accounts', forControlEvents: UIControlEventTouchUpInside)
    @state_button   .addTarget(self, action: 'toggle_state',          forControlEvents: UIControlEventTouchUpInside)
  end

  def didMoveToParentViewController(_)
    @account = Player.first.accounts[Player.first.current_account]
    @layout.get(:username).text      = @account.username
    @layout.get(:survival_time).text = survival_time(@account)
    set_state_image
  end

  def push_user_to_vision
    parentViewController.start_vision(self)
  end

  def push_user_to_map
    parentViewController.start_map(self)
  end

  def push_user_to_accounts
    parentViewController.start_accounts_page(self)
  end

  def toggle_state
    @account.state = !@account.state?
    cdq.save
    set_state_image
  end

  def set_state_image
    if @account.state?
      @layout.get(:state_image_view).image = UIImage.imageNamed('pause')
    else
      @layout.get(:state_image_view).image = UIImage.imageNamed('play')
    end
  end
end