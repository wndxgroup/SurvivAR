class AccountsListController < UIViewController
  include SurvivalTime

  attr_accessor :add_icon_view

  def init
    super
    self.title = 'Accounts'
    @table = UITableView.new
    self
  end

  def viewDidLoad
    super
    add_icon = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAdd, target: self, action: 'add_an_account')
    navigationItem.rightBarButtonItem = add_icon
    @player = Player.first
    add_table
  end

  def viewWillAppear(_)
    @table.reloadData
  end

  def add_table
    @table.frame = [[0, 0], [view.frame.size.width, view.frame.size.height]]
    view.addSubview(@table)
    @table.dataSource = @table.delegate = self
  end

  def add_an_account
    navigationController.pushViewController(CreateAnAccountController.new, animated: true)
  end

  def tableView(_, numberOfRowsInSection: _)
    @player.accounts.count
  end

  CELLID = 'CellIdentifier'
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(CELLID) || begin
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:CELLID)
      cell
    end
    account = @player.sorted_accounts[indexPath.row]
    additional_info = '💀' if !account.alive?
    cell.textLabel.text = "#{account.username} #{additional_info}"
    cell.detailTextLabel.text = "#{account.kills} kills in #{survival_time(account)}"
    cell
  end

  def tableView(_, didSelectRowAtIndexPath: indexPath)
    @player.sorted_accounts[@player.current_account].start_time = nil if @player.current_account
    @player.current_account = indexPath.row
    cdq.save
    if @player.sorted_accounts[@player.current_account].alive?
      if navigationController.viewControllers.count == 1
        navigationController.setViewControllers([MenuController.new], animated: true)
      else
        navigationController.popViewControllerAnimated(true)
      end
    else
      navigationController.pushViewController(DeathController.new, animated: true)
    end
  end
end