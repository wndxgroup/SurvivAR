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
  end

  def tableView(_, numberOfRowsInSection: _)
    13
  end

  CELLID = 'CellIdentifier'
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(CELLID) || begin
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:CELLID)
      cell
    end
    account = @player.sorted_accounts[indexPath.row]
    cell.textLabel.text = account.username
    cell
  end

  def viewWillAppear(_)
    @quick_view_container.layer.cornerRadius = 10
    @quick_view_container.clipsToBounds = true
    @username.text = @account.username
    if @account.alive
      @quick_view_title.text = 'Current Round'
      @quick_view_kills.text += "\n#{@account.kills}"
      @quick_view_time.text += "\n#{survival_time(@account)}"
      @battleground_button.text = 'Continue Round'
    else
      @quick_view_title.text = 'Best Round'
      @battleground_button.text = 'Start New Round'
    end

    if logged_in_to_this_account
      @toggle_log_button.text = 'Log Out'
      @toggle_log_button.backgroundColor = UIColor.orangeColor
    else
      @toggle_log_button.text = 'Log In'
      @toggle_log_button.backgroundColor = UIColor.alloc.initWithRed(66.0/255, green: 182.0/255, blue: 244.0/255, alpha: 1.0)
    end
  end

  def logged_in_to_this_account
    @player.sorted_accounts[@player.current_account].username == @account.username
  end
end