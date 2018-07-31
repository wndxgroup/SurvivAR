class LeaderboardController < UIViewController
  include Rankings

  def loadView
    self.title = 'Leaderboard'
    @layout = LeaderboardLayout.new
    self.view = @layout.view
    @layout.add_constraints

    @table = @layout.get(:table)
    @player = Player.first
    @most_kills_button   = @layout.get(:most_kills)
    @longest_life_button = @layout.get(:longest_life)
    @filter = 'most kills'
  end

  def viewDidLoad
    @table.dataSource = @table.delegate = self
    @most_kills_button.addTarget(self, action: 'filter_by_kills', forControlEvents: UIControlEventTouchUpInside)
    @longest_life_button.addTarget(self, action: 'filter_by_survival_time', forControlEvents: UIControlEventTouchUpInside)
    filter_by_kills
  end

  def set_filter_buttons
    if @filter == 'most kills'
      @most_kills_button.backgroundColor = UIColor.colorWithRed(1.0, green: 0, blue: 0, alpha: 1)
      @longest_life_button.backgroundColor = UIColor.colorWithRed(0.5, green: 0, blue: 0, alpha: 1)
    else
      @most_kills_button.backgroundColor = UIColor.colorWithRed(0.5, green: 0, blue: 0, alpha: 1)
      @longest_life_button.backgroundColor = UIColor.colorWithRed(1.0, green: 0, blue: 0, alpha: 1)
    end
    @table.reloadData
  end

  def filter_by_kills
    @filter = 'most kills'
    determine_kills_rankings unless @most_kills
    set_filter_buttons
  end

  def filter_by_survival_time
    @filter = 'survival time'
    determine_life_rankings unless @longest_life
    set_filter_buttons
  end

  def tableView(_, numberOfRowsInSection: _)
    @player.accounts.map{|acct| acct.rounds.count}.inject(0){|sum, x| sum + x}
  end

  CELLID = 'CellIdentifier'
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(CELLID) || begin
      cell = UITableViewCell.alloc.initWithStyle(UITableViewCellStyleSubtitle, reuseIdentifier:CELLID)
      cell
    end
    round = @filter == 'most kills' ? @most_kills[indexPath.row] : @longest_life[indexPath.row]
    text_label = "#{round.account.username}"
    if indexPath.row == 0
      text_label += ' 🥇'
    elsif indexPath.row == 1
      text_label += ' 🥈'
    elsif indexPath.row == 2
      text_label += ' 🥉'
    end
    cell.textLabel.text = text_label
    cell.detailTextLabel.text = "#{round.kills} kills in #{round.survival_time}"
    cell
  end
end