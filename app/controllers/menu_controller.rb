class MenuController < UIViewController
  include SurvivalTime

  attr_accessor :queue

  def loadView
    @layout = MenuLayout.new
    self.view = @layout.view
    @layout.add_constraints

    @vision_button   = @layout.get(:vision_button)
    @map_button      = @layout.get(:map_button)
    @accounts_button = @layout.get(:accounts_button)
    @state_button    = @layout.get(:state_button)
    @survival_clock  = @layout.get(:survival_time)
  end

  def viewDidLoad
    @vision_button  .addTarget(self, action: 'push_user_to_vision',   forControlEvents: UIControlEventTouchUpInside)
    @map_button     .addTarget(self, action: 'push_user_to_map',      forControlEvents: UIControlEventTouchUpInside)
    @accounts_button.addTarget(self, action: 'push_user_to_accounts', forControlEvents: UIControlEventTouchUpInside)
    @state_button   .addTarget(self, action: 'toggle_state',          forControlEvents: UIControlEventTouchUpInside)
  end

  def didMoveToParentViewController(_)
    @player = Player.first
    @logged_in_account = @player.sorted_accounts[@player.current_account]
    @player.sorted_accounts.each {|acct| @ticking_account = acct if acct.state? }
    @layout.get(:username).text = @logged_in_account.username
    calculate_survival_time_increase(@logged_in_account) unless @logged_in_account.start_time.nil?
    @survival_clock.text = survival_time(@logged_in_account)
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
    @logged_in_account.state = !@logged_in_account.state?
    pause_other_accounts
    set_state_image
  end

  def pause_other_accounts
    @player.accounts.each {|acct| acct.state = false if acct != @logged_in_account}
  end

  def tick_survival_clock(account)
    loop do
      sleep 1
      break if @tick == false
      calculate_survival_time_increase(account)
      Dispatch::Queue.main.sync do
        cdq.save
        @survival_clock.text = survival_time(account) if account == @logged_in_account
      end
    end
  end

  def set_state_image
    if @logged_in_account.state?
      @layout.get(:state_image_view).image = UIImage.imageNamed('pause')
      @logged_in_account.start_time = Time.now if @logged_in_account.start_time.nil?
      # set_wave_time
      unless @tick == true
        @tick = true
        queue = Dispatch::Queue.new('tick_tock')
        queue.async { tick_survival_clock(@logged_in_account) }
      end
    else
      @layout.get(:state_image_view).image = UIImage.imageNamed('play')
      @logged_in_account.start_time = nil
      @tick = false
      if @ticking_account
        queue = Dispatch::Queue.new('start_a_new_ticker')
        queue.async { start_a_new_ticker}
      end
    end
    cdq.save
  end

  def start_a_new_ticker
    sleep 1.01
    @tick = true
    tick_survival_clock(@ticking_account)
  end

  # def set_wave_time
  #   @player.accounts.each do |acct|
  #     if acct.state
  #   end
  #   set_wave_notification(time)
  # end

  def set_wave_notification(seconds)
    center = UNUserNotificationCenter.currentNotificationCenter
    center.requestAuthorizationWithOptions(UNAuthorizationOptionAlert,
                                           completionHandler: lambda { |granted, error| })
    content = UNMutableNotificationContent.new
    content.title = "Wave 2 Started"
    content.body = "You've got 20 seconds"
    trigger = UNTimeIntervalNotificationTrigger.triggerWithTimeInterval(seconds, repeats: false)
    notification = UNNotificationRequest.requestWithIdentifier('asdf', content: content, trigger: trigger)
    center.addNotificationRequest(notification,
                                  withCompletionHandler: lambda { |error| })
  end
end