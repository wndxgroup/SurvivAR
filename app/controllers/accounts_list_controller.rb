class AccountsListController < UIViewController
  include SurvivalTime

  attr_accessor :add_icon_view

  def init
    super
    @table = UITableView.new
    self
  end

  def viewDidLoad
    add_header
    add_table
  end

  def viewWillAppear(_)
    @table.reloadData
  end

  def didMoveToParentViewController(_)
    update_header_buttons
    @table.reloadData
    unless @updating_survival_timer
      @updating_survival_timer = true
      @break_survival_timer_loop = false
      @player.sorted_accounts.each.with_index do |acct, i|
        if acct.start_time
          queue = Dispatch::Queue.new('update_cell_survival_timer')
          queue.async { update_cell_survival_timer(acct, i) }
          break
        end
      end
    end
  end

  def update_header_buttons
    if view.subviews[0]
      view.subviews[0].removeFromSuperview
      add_header
      add_table
    end
  end

  def update_cell_survival_timer(account, account_index)
    loop do
      break if @break_survival_timer_loop
      @table.indexPathsForVisibleRows.each do |path|
        if path.row == account_index
          Dispatch::Queue.main.sync do
            @table.cellForRowAtIndexPath(path).detailTextLabel.text = survival_time(account)
          end
          break
        end
      end
    end
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

    @player ||= Player.first
    icon_width = 40
    if @player.current_account && @player.sorted_accounts[@player.current_account].alive?
      @back_icon_view = UIView.new
      @back_icon_view.frame = [[20, bar_height / 2 - icon_width / 2], [icon_width, icon_width]]
      back_icon = UIImage.imageNamed('back')
      back_icon_parent = UIImageView.alloc.initWithImage(back_icon)
      back_icon_parent.frame = [[0, 0], [icon_width, icon_width]]
      @back_icon_view.addSubview(back_icon_parent)
      bar.addSubview(@back_icon_view)
    end

    @add_icon_view = UIView.new
    @add_icon_view.frame = [[view.frame.size.width - icon_width - 20, bar_height / 2 - icon_width / 2], [icon_width, icon_width]]
    add_icon = UIImage.imageNamed('add')
    add_icon_parent = UIImageView.alloc.initWithImage(add_icon)
    add_icon_parent.frame = [[0, 0], [icon_width, icon_width]]
    @add_icon_view.addSubview(add_icon_parent)
    bar.addSubview(@add_icon_view)
  end

  def add_table
    @table.frame = [[0, 70], [view.frame.size.width, view.frame.size.height - 70]]
    view.addSubview(@table)
    @table.dataSource = @table.delegate = self
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
    additional_info = '(RIP)' if !account.alive?
    cell.textLabel.text = "#{account.username} #{additional_info}"
    cell.detailTextLabel.text = survival_time(account)
    cell
  end

  def tableView(_, didSelectRowAtIndexPath: indexPath)
    @break_survival_timer_loop = true
    @updating_survival_timer = false
    @player.sorted_accounts[@player.current_account].start_time = nil if @player.current_account
    @player.current_account = indexPath.row
    cdq.save
    if @player.current_account && @player.sorted_accounts[@player.current_account].alive?
      parentViewController.set_controller(parentViewController.menu_controller, from: self)
    else
      parentViewController.set_controller(parentViewController.death_controller, from: self)
    end
  end

  def touchesEnded(_, withEvent: event)
    if event.touchesForView(@add_icon_view)
      if @player.current_account
        @player.sorted_accounts[@player.current_account].start_time = nil
        @player.current_account = nil
        cdq.save
      end
      @break_survival_timer_loop = true
      @updating_survival_timer = false
      parentViewController.set_controller(parentViewController.create_an_account_controller, from: self)
    elsif event.touchesForView(@back_icon_view)
      @break_survival_timer_loop = true
      @updating_survival_timer = false
      parentViewController.set_controller(parentViewController.menu_controller, from: self)
    end
  end
end