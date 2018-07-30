class AccountsListController < UITableViewController
  include SurvivalTime

  attr_accessor :add_icon_view

  def init
    super
    self.title = 'Accounts'
    self
  end

  def viewDidLoad
    super
    add_icon = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAdd, target: self, action: 'add_an_account')
    navigationItem.rightBarButtonItem = add_icon
    @player = Player.first
  end

  def viewWillAppear(_)
    tableView.reloadData
  end

  def add_an_account
    navigationController.pushViewController(CreateAnAccountController.new, animated: true)
  end

  def tableView(_, trailingSwipeActionsConfigurationForRowAtIndexPath: indexPath)
    handler = lambda do |action, sourceView, completionHandler|
      alert = UIAlertController.alertControllerWithTitle('Are You Sure?',
                                                         message: 'Account deletion can\'t be undone.',
                                                         preferredStyle: UIAlertControllerStyleAlert)
      cancel_action = UIAlertAction.actionWithTitle('Cancel', style: UIAlertActionStyleCancel, handler: lambda {|_| completionHandler.call(false)})
      continue_action = UIAlertAction.actionWithTitle('Delete', style: UIAlertActionStyleDefault, handler: lambda { |_| delete_account(indexPath.row); completionHandler.call(true)})
      alert.addAction(cancel_action)
      alert.addAction(continue_action)
      presentViewController(alert, animated: true, completion: nil)
    end
    action = UIContextualAction.contextualActionWithStyle(UIContextualActionStyleDestructive,
                                                          title: 'Delete',
                                                          handler: handler)
    UISwipeActionsConfiguration.configurationWithActions([action])
  end

  def delete_account(index)
    update_current_account(index)
    @player.sorted_accounts[index].destroy
    cdq.save
    tableView.reloadData
  end

  def update_current_account(index)
    if index < @player.current_account
      @player.current_account -= 1
    elsif index == @player.current_account
      @player.current_account = nil
    end
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
    cell.textLabel.text += ' 🔵' if @player.current_account == indexPath.row
    cell
  end

  def tableView(_, didSelectRowAtIndexPath: indexPath)
    controller = MyAccountController.new
    controller.set_account(indexPath.row)
    navigationController.pushViewController(controller, animated: true)
  end
end