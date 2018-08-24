class MyAccountController < UIViewController
  include Recorder, Colors

  def init
    super
    self.title = 'My Account'
    self
  end

  def set_account(account_number)
    @player = Player.first
    @account = @player.sorted_accounts[account_number]
  end

  def loadView
    @layout = MyAccountLayout.new
    self.view = @layout.view
    @layout.add_constraints

    quick_view_container  = @layout.get(:quick_view_container)
    @battleground_button  = @layout.get(:start_battleground)
    @toggle_log_button    = @layout.get(:toggle_log)
    delete_account_button = @layout.get(:delete_account)
    history_table         = @layout.get(:history_table)

    history_table.dataSource = history_table.delegate = self
    quick_view_container.layer.cornerRadius = 10
    quick_view_container.clipsToBounds = true

    @battleground_button .addTarget(self, action: 'start_battleground',       forControlEvents: UIControlEventTouchUpInside)
    @toggle_log_button   .addTarget(self, action: 'toggle_log',               forControlEvents: UIControlEventTouchUpInside)
    delete_account_button.addTarget(self, action: 'confirm_account_deletion', forControlEvents: UIControlEventTouchUpInside)
  end

  def viewWillAppear(animated)
    super
    @layout.get(:username)         .text = @account.username
    @layout.get(:quick_view_kills) .text = "💥\n#{overall_kills}"
    @layout.get(:quick_view_time)  .text = "🕒\n#{overall_survival_time}"
    @layout.get(:quick_view_rounds).text = "💀\n#{overall_rounds}"

    if @account.alive?
      @battleground_button.setTitle('Continue Battleground', forState: UIControlStateNormal)
    else
      @battleground_button.setTitle('New Battleground', forState: UIControlStateNormal)
    end
    set_toggle_log_button
  end

  def tableView(_, numberOfRowsInSection: _)
    @account.rounds.count
  end

  CELLID = 'CellIdentifier'
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(CELLID) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: CELLID)
    end
    num_rounds = @account.sorted_rounds.count - 1
    round = @account.sorted_rounds[num_rounds - indexPath.row]
    cell.textLabel.text = "#{round.kills} kills in #{round.survival_time}"
    cell
  end

  def overall_kills
    kills = @account.rounds.map {|acct| acct.kills} .inject(0) {|sum, x| sum + x}
    kills += @account.kills if @account.alive?
    kills
  end

  def overall_survival_time
    completed_survival_times = @account.rounds.map{|acct| acct.survival_time}
    hours = minutes = seconds = 0
    completed_survival_times.each do |time|
      survival_time = time.split(':')
      hours   += survival_time[0].to_i
      minutes += survival_time[1].to_i
      seconds += survival_time[2].to_i
    end
    if seconds >= 60
      mins_to_add = (seconds / 60.0).floor
      seconds -= mins_to_add * 60
      minutes += mins_to_add
    end
    if minutes >= 60
      hours_to_add = (minutes / 60.0).floor
      minutes -= hours_to_add * 60
      hours += hours_to_add
    end
    hours   = hours.to_s
    minutes = minutes.to_s
    seconds = seconds.to_s
    hours   = '0' + hours   if hours.length   == 1
    minutes = '0' + minutes if minutes.length == 1
    seconds = '0' + seconds if seconds.length == 1
    "#{hours}:#{minutes}:#{seconds}"
  end

  def overall_rounds
    @account.rounds.count
  end

  def start_battleground
    unless logged_in_to_this_account
      @player.current_account = @player.sorted_accounts.index(@account)
      cdq.save
    end
    initiate_recording
    app_delegate = UIApplication.sharedApplication.delegate
    menu         = app_delegate.menu_controller
    battleground = app_delegate.battleground_controller
    navigationController.setViewControllers([menu, battleground], animated: true)
  end

  def set_toggle_log_button
    if logged_in_to_this_account
      @toggle_log_button.setTitle('Log Out', forState: UIControlStateNormal)
      @toggle_log_button.backgroundColor = UIColor.orangeColor
    else
      @toggle_log_button.setTitle('Log In', forState: UIControlStateNormal)
      @toggle_log_button.backgroundColor = UIColor.alloc.initWithRed(66.0/255, green: 182.0/255, blue: 244.0/255, alpha: 1.0)
    end
  end

  def toggle_log
    if logged_in_to_this_account
      @player.current_account = nil
    else
      @player.current_account = @player.sorted_accounts.index(@account)
    end
    cdq.save
    set_toggle_log_button
  end

  def confirm_account_deletion
    alert = UIAlertController.alertControllerWithTitle('Are You Sure?',
                                                       message: 'Account deletion can\'t be undone.',
                                                       preferredStyle: UIAlertControllerStyleAlert)
    cancel_action = UIAlertAction.actionWithTitle('Cancel', style: UIAlertActionStyleCancel, handler: nil)
    continue_action = UIAlertAction.actionWithTitle('Delete', style: UIAlertActionStyleDefault, handler: lambda { |_| delete_account})
    alert.addAction(cancel_action)
    alert.addAction(continue_action)
    presentViewController(alert, animated: true, completion: nil)
  end

  def delete_account
    update_current_account if @player.current_account
    @account.destroy
    cdq.save
    navigationController.popViewControllerAnimated(true)
  end

  def update_current_account
    acct_index = @player.sorted_accounts.index(@account)
    if acct_index < @player.current_account
      @player.current_account -= 1
    elsif acct_index == @player.current_account
      @player.current_account = nil
    end
  end

  def logged_in_to_this_account
    return false if @player.current_account.nil?
    @player.sorted_accounts[@player.current_account].username == @account.username
  end
end