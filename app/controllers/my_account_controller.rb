class MyAccountController < UIViewController
  include SurvivalTime

  def set_account(account_number)
    @player = Player.first
    @account = @player.sorted_accounts[account_number]
  end

  def loadView
    self.title = 'My Account'
    @layout = MyAccountLayout.new
    self.view = @layout.view
    @layout.add_constraints

    @username = @layout.get(:username)
    @quick_view_container = @layout.get(:quick_view_container)
    @quick_view_title = @layout.get(:quick_view_title)
    @quick_view_kills = @layout.get(:quick_view_kills)
    @quick_view_time  = @layout.get(:quick_view_time)
    @battleground_button = @layout.get(:start_battleground)
    @toggle_log_button   = @layout.get(:toggle_log)
    @history_table       = @layout.get(:history_table)
  end

  def viewDidLoad
    @history_table.dataSource = @history_table.delegate = self
    @toggle_log_button.addTarget(self, action: 'toggle_log', forControlEvents: UIControlEventTouchUpInside)
  end

  def tableView(_, numberOfRowsInSection: _)
    @account.rounds.count
  end

  CELLID = 'CellIdentifier'
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(CELLID) || begin
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:CELLID)
      cell
    end
    cell.textLabel.text = "#{@account.sorted_rounds[indexPath.row].kills} kills in #{@account.sorted_rounds[indexPath.row].survival_time}"
    cell
  end

  def viewWillAppear(_)
    @quick_view_container.layer.cornerRadius = 10
    @quick_view_container.clipsToBounds = true
    @username.text = @account.username
    if @account.alive?
      @quick_view_title.text = 'Current Round'
      @quick_view_kills.text += "\n#{@account.kills}"
      @quick_view_time.text += "\n#{survival_time(@account)}"
      @battleground_button.text = 'Continue Round'
    else
      @quick_view_title.text = 'Most Kills Round'
      round = @account.most_kills_round
      @quick_view_kills.text += "\n#{@account.rounds[round].kills}"
      @quick_view_time.text += "\n#{@account.rounds[round].survival_time}"
      @battleground_button.text = 'Start New Round'
    end
    set_toggle_log_button
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
      @player.current_account = @player.sorted_accounts.index{|acct| acct.username == @username.text}
    end
    set_toggle_log_button
  end

  def logged_in_to_this_account
    return false if @player.current_account == nil
    @player.sorted_accounts[@player.current_account].username == @account.username
  end
end