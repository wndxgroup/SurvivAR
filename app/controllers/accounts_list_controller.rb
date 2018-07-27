class AccountsListController < UITableViewController
  include SurvivalTime

  attr_accessor :add_icon_view

  def init
    super
    self.title = 'Accounts'
    # @table = UITableView.new
    self
  end

  def viewDidLoad
    super
    add_icon = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAdd, target: self, action: 'add_an_account')
    navigationItem.rightBarButtonItem = add_icon
    @player = Player.first
  end

  # def viewWillAppear(_)
  #   @table.reloadData
  # end

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
    cell.textLabel.text = account.username
    cell
  end

  def tableView(_, didSelectRowAtIndexPath: indexPath)
    controller = MyAccountController.new
    controller.set_account(indexPath.row)
    navigationController.pushViewController(controller, animated: true)
  end
end