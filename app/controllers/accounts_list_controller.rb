class AccountsListController < UITableViewController

  def viewDidLoad
    super
    self.title = 'Accounts'
    add_icon = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAdd,
                                                                 target: self,
                                                                 action: 'add_an_account')
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
    handler = lambda do |_, _, completionHandler|
      alert = UIAlertController.alertControllerWithTitle('Are You Sure?',
                                                         message: 'Account deletion can\'t be undone.',
                                                         preferredStyle: UIAlertControllerStyleAlert)
      cancel_action = UIAlertAction.actionWithTitle('Cancel',
                                                    style: UIAlertActionStyleCancel,
                                                    handler: lambda {|_| completionHandler.call(false)})
      continue_action_handler = lambda do |_|
        delete_account(indexPath.row)
        completionHandler.call(true)
      end
      continue_action = UIAlertAction.actionWithTitle('Delete',
                                                      style: UIAlertActionStyleDefault,
                                                      handler: continue_action_handler)
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
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: CELLID)
    end
    account = @player.sorted_accounts[indexPath.row]
    text_label = ''
    if @player.current_account == indexPath.row
      text_label = '🔵 '
    else
      text_label = '⚫ '
    end
    text_label += account.username
    cell.textLabel.text = text_label
    cell
  end

  def tableView(_, didSelectRowAtIndexPath: indexPath)
    controller = MyAccountController.new
    controller.set_account(indexPath.row)
    navigationController.pushViewController(controller, animated: true)
  end
end