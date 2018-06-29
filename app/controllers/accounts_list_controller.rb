class AccountsListController < UIViewController
  include SurvivalTime

  attr_accessor :add_icon_view

  def viewDidLoad
    add_header
    add_table
  end

  def didMoveToParentViewController(_)
    @table.reloadData
  end

  def add_header
    bar_height = 70

    bar = UIView.new
    bar.frame = [[0 , 0], [view.frame.size.width, bar_height]]
    bar.backgroundColor = UIColor.colorWithRed(1, green: 189.0/255, blue: 74.0/255, alpha: 1)
    view.addSubview(bar)

    title_width = 120
    title_height = 50
    title = UITextView.new.tap do |t|
      t.text = 'Accounts'
      t.frame = [[view.frame.size.width / 2 - title_width / 2, bar_height / 2 - title_height / 2], [title_width, title_height]]
      t.font = UIFont.systemFontOfSize(24)
      t.backgroundColor = UIColor.colorWithRed(1, green: 189.0/255, blue: 74.0/255, alpha: 1)
      t.editable = false
      t.selectable = false
    end
    bar.addSubview(title)

    icon_width = 40
    @back_icon_view = UIView.new
    @back_icon_view.frame = [[20, bar_height / 2 - icon_width / 2], [icon_width, icon_width]]
    back_icon = UIImage.imageNamed('back')
    back_icon_parent = UIImageView.alloc.initWithImage(back_icon)
    back_icon_parent.frame = [[0, 0], [icon_width, icon_width]]
    @back_icon_view.addSubview(back_icon_parent)
    bar.addSubview(@back_icon_view)

    @add_icon_view = UIView.new
    @add_icon_view.frame = [[view.frame.size.width - icon_width - 20, bar_height / 2 - icon_width / 2], [icon_width, icon_width]]
    add_icon = UIImage.imageNamed('add')
    add_icon_parent = UIImageView.alloc.initWithImage(add_icon)
    add_icon_parent.frame = [[0, 0], [icon_width, icon_width]]
    @add_icon_view.addSubview(add_icon_parent)
    bar.addSubview(@add_icon_view)
  end

  def add_table
    @table = UITableView.new
    @table.frame = [[0, 70], [view.frame.size.width, view.frame.size.height - 70]]
    view.addSubview(@table)
    @table.dataSource = @table.delegate = self
  end

  def tableView(_, numberOfRowsInSection: _)
    Player.first.accounts.count
  end

  CELLID = 'CellIdentifier'
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(CELLID) || begin
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:CELLID)
      cell
    end
    account = Player.first.accounts[indexPath.row]
    cell.textLabel.text = account.username
    cell.detailTextLabel.text = survival_time(account)
    cell
  end

  def tableView(_, didSelectRowAtIndexPath: indexpath)
    Player.first.current_account = indexpath.row
    parentViewController.set_controller(parentViewController.menu_controller, from: self)
  end

  def touchesEnded(_, withEvent: event)
    if event.touchesForView(@add_icon_view)
      parentViewController.set_controller(parentViewController.create_an_account_controller, from: self)
    elsif event.touchesForView(@back_icon_view)
      parentViewController.set_controller(parentViewController.menu_controller, from: self)
    end
  end
end