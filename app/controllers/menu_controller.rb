class MenuController < UIViewController
  include SurvivalTime

  attr_accessor :queue

  def init
    super
      @center = UNUserNotificationCenter.currentNotificationCenter
    self
  end

  def loadView
    @layout = MenuLayout.new
    self.view = @layout.view
    @layout.add_constraints

    @vision_button   = @layout.get(:vision_button)
    @map_button      = @layout.get(:map_button)
    @accounts_button = @layout.get(:accounts_button)
    @ticking_button    = @layout.get(:ticking_button)
    @survival_clock  = @layout.get(:survival_time)
  end

  def viewDidLoad
    @vision_button  .addTarget(self, action: 'push_user_to_vision',   forControlEvents: UIControlEventTouchUpInside)
    @map_button     .addTarget(self, action: 'push_user_to_map',      forControlEvents: UIControlEventTouchUpInside)
    @accounts_button.addTarget(self, action: 'push_user_to_accounts', forControlEvents: UIControlEventTouchUpInside)
    @ticking_button .addTarget(self, action: 'toggle_ticking',        forControlEvents: UIControlEventTouchUpInside)
  end

  def didMoveToParentViewController(_)
    @player = Player.first
    @current_account = @player.sorted_accounts[@player.current_account]
    @ticking_account = nil
    @player.sorted_accounts.each {|acct| @ticking_account = acct if acct.ticking? }
    @layout.get(:username).text = @current_account.username
    calculate_survival_time_increase(@current_account) unless @current_account.start_time.nil?
    @survival_clock.text = survival_time(@current_account)
    set_ticking_image
    initiate_survival_clock
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

  def push_user_to_death_screen
    parentViewController.set_controller(parentViewController.death_controller, from: self)
  end

  def toggle_ticking
    if @ticking_account && @ticking_account.seconds_to_next_wave <= 0
      alert_user_of_ongoing_wave
      return
    end
    @current_account.ticking = !@current_account.ticking?
    cdq.save
    set_new_ticking_and_current_accounts
    update_notifications
    set_ticking_image
    initiate_survival_clock
  end

  def alert_user_of_ongoing_wave
    alert = UIAlertController.alertControllerWithTitle('Wave In Progress',
                                                       message: 'Nice try. You can\'t pause a wave.',
                                                       preferredStyle: UIAlertControllerStyleAlert)
    action = UIAlertAction.actionWithTitle('Continue battle',
                                           style: UIAlertActionStyleDefault,
                                           handler: nil)
    alert.addAction(action)
    self.presentViewController(alert, animated: true, completion: nil)
  end

  def set_new_ticking_and_current_accounts
    if @current_account.ticking?
      @ticking_account = @current_account
      @player.ticking_account = @player.sorted_accounts.index(@current_account)
    else
      @ticking_account = @player.ticking_account = nil
    end
  end

  def update_notifications
    if @ticking_account
      set_wave_notification(@current_account.seconds_to_next_wave)
    else
      @center.removeAllPendingNotificationRequests
    end
  end

  def set_ticking_image
    if @current_account.ticking?
      @layout.get(:ticking_image_view).image = UIImage.imageNamed('pause')
    else
      @layout.get(:ticking_image_view).image = UIImage.imageNamed('play')
    end
  end

  def initiate_survival_clock
    if @current_account.ticking?
      pause_other_accounts
      unless @current_account.start_time
        @current_account.start_time = Time.now
      end
      Dispatch::Queue.new('start survival session').async { @current_account.start_survival_session }
      Dispatch::Queue.new('update survival clock').async { update_survival_clock }
    else
      @current_account.stop_survival_session
    end
  end

  def pause_other_accounts
    @player.accounts.each {|acct| acct.stop_survival_session if acct != @current_account}
  end

  def update_survival_clock
    while @current_account.ticking? do
      Dispatch::Queue.main.sync do
        @survival_clock.text = survival_time(@current_account)
        push_user_to_death_screen unless @current_account.alive?
      end
    end
  end

  def set_wave_notification(seconds)
    @center.requestAuthorizationWithOptions(UNAuthorizationOptionAlert | UNAuthorizationOptionSound,
                                            completionHandler: lambda { |granted, error| })
    @center.delegate = self
    content = UNMutableNotificationContent.new
    content.title = "Wave #{@ticking_account.wave + 1} Started"
    content.body = 'You\'ve got 30 seconds until they get you.'
    content.sound = UNNotificationSound.soundNamed('wave-sound.wav')
    trigger = UNTimeIntervalNotificationTrigger.triggerWithTimeInterval(seconds, repeats: false)
    notification = UNNotificationRequest.requestWithIdentifier('_', content: content, trigger: trigger)
    @center.addNotificationRequest(notification, withCompletionHandler: lambda { |error| })
  end

  def userNotificationCenter(center, willPresentNotification: response, withCompletionHandler: completion_handler)
    increase_wave_number
    play_wave_sound
    start_wave
    alert_user_of_wave

    completion_handler.call(UNNotificationPresentationOptionSound)
  end

  def userNotificationCenter(center, didReceiveNotificationResponse: response, withCompletionHandler: completion_handler)
    increase_wave_number
    push_user_to_map

    completion_handler.call
  end

  def increase_wave_number
    @ticking_account.wave += 1
    cdq.save
  end

  def start_wave

  end

  def play_wave_sound
    path = NSBundle.mainBundle.pathForResource('wave-sound', ofType:'wav')
    pathURL = NSURL.fileURLWithPath(path)
    sound_id = Pointer.new('I')
    AudioServicesCreateSystemSoundID(pathURL, sound_id)
    AudioServicesPlaySystemSound(sound_id[0])
  end

  def alert_user_of_wave
    alert = UIAlertController.alertControllerWithTitle("Wave #{@ticking_account.wave} Started",
                                                       message: 'You\'ve got 30 seconds until they get you.',
                                                       preferredStyle: UIAlertControllerStyleAlert)
    action = UIAlertAction.actionWithTitle('See Map',
                                           style: UIAlertActionStyleDefault,
                                           handler: lambda {|_| push_user_to_map})
    alert.addAction(action)
    self.presentViewController(alert, animated: true, completion: nil)
  end
end